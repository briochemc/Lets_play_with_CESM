;
; gen_IRF_offline_transport.ncl
;

begin
   basis_function_dir = "/glade/p/cesm/bgcwg/klindsay/IRF/"

   stencil_width = 5

   setfileoption("nc","Format","NetCDF4Classic")
   setfileoption("nc","CompressionLevel",1)

   grid_name = "gx1v6"

   grid_dir = "/glade/p/cesm/bgcwg/klindsay/"
   grid_fname = grid_name+"_grid_specs.nc"
   fin = addfile(grid_dir+grid_fname, "r")
   KMT = fin->KMT
   TLONG = fin->TLONG
   TLAT = fin->TLAT
   z_t = fin->z_t
   delete(fin)

   km = dimsizes(z_t)
   tmp = dimsizes(KMT)
   nlat = tmp(0)
   nlon = tmp(1)
   delete(tmp)

   msv = -1.0

   basis_function = new((/ km, nlat, nlon /), "double", msv)
   basis_function!0 = "z_t"
   basis_function&z_t = z_t
   basis_function!1 = "nlat"
   basis_function!2 = "nlon"
   basis_function@coordinates = "TLONG TLAT z_t"

   land_mask = basis_function
   do j = 0, nlat-1
   do i = 0, nlon-1
      if (KMT(j,i) .gt. 0) then
         land_mask(0:KMT(j,i)-1,j,i) = 0.0
      end if
   end do
   end do

   if (grid_name .eq. "gx3v7") then
      src_imin = (/   8,  13,  59,  98 /)
      src_imax = (/  10,  15,  62, 100 /)
      src_jmin = (/ 109,  93,   2,   2 /)
      src_jmax = (/ 112,  97,   3,   3 /)
      src_kmin = (/  33,  38,  34,  36 /)
      src_kmax = (/  33,  38,  34,  36 /)
      ent_imin = (/   3,   7,  59,  96 /)
      ent_imax = (/   5,  10,  61,  98 /)
      ent_jmin = (/ 104,  93,   6,   6 /)
      ent_jmax = (/ 107,  96,   8,   8 /)
      ent_kmin = (/  39,  40,  40,  40 /)
      ent_kmax = (/  39,  40,  40,  40 /)
   end if

   if (grid_name .eq. "gx1v6") then
      src_imin = (/  20,  39, 196,   5 /)
      src_imax = (/  30,  42, 200,   8 /)
      src_jmin = (/ 370, 349,   4,   6 /)
      src_jmax = (/ 372, 355,   6,   8 /)
      src_kmin = (/  33,  38,  34,  36 /)
      src_kmax = (/  33,  38,  34,  36 /)
      ent_imin = (/  12,  28, 194,   1 /)
      ent_imax = (/  15,  31, 196,   3 /)
      ent_jmin = (/ 363, 352,  13,  11 /)
      ent_jmax = (/ 367, 355,  17,  13 /)
      ent_kmin = (/  39,  40,  40,  40 /)
      ent_kmax = (/  39,  40,  40,  40 /)
   end if

   overflow_cnt = dimsizes(src_imin)
   print("overflow_cnt = "+overflow_cnt)

   fout_name = basis_function_dir+"IRF_offline_transport_tracers_"+grid_name+".nc"
   system("rm -f "+fout_name)
   fout = addfile(fout_name, "c")

   filedimdef(fout, (/ "z_t", "nlat", "nlon" /), (/ km, nlat, nlon /) , (/ False, False, False /))

   fout->KMT = KMT
   fout->TLONG = TLONG
   fout->TLAT = TLAT
   fout->z_t = z_t

   overflow_src_basis_count = max((src_imax-src_imin+1)*(src_jmax-src_jmin+1)*(src_kmax-src_kmin+1))
   print("overflow_src_basis_count = "+overflow_src_basis_count)
   overflow_ent_basis_count = max((ent_imax-ent_imin+1)*(ent_jmax-ent_jmin+1)*(ent_kmax-ent_kmin+1))
   print("overflow_ent_basis_count = "+overflow_ent_basis_count)
   total_basis_count = stencil_width*stencil_width*stencil_width + overflow_src_basis_count + overflow_ent_basis_count
   print("total_basis_count = "+total_basis_count)

   var_names = new(total_basis_count, string)

   ;
   ; define impulse variables in output file
   ;

   var_ind = 0
   do k = 1, stencil_width ; index is 1 based
      do j = 1, stencil_width ; index is 1 based
         do i = 1, stencil_width ; index is 1 based
            var_names(var_ind) = "IRF_"+sprinti("%0.1i",i)+"_"+sprinti("%0.1i",j)+"_"+sprinti("%0.1i",k)
            filevardef(fout, var_names(var_ind), "double", (/ "z_t", "nlat", "nlon" /))
            filevarattdef(fout, var_names(var_ind), basis_function)
            var_ind = var_ind + 1
         end do
      end do
   end do

   do n = 0, overflow_src_basis_count-1
      var_names(var_ind) = "IRF_OVF_SRC_"+sprinti("%0.2i",n+1)
      filevardef(fout, var_names(var_ind), "double", (/ "z_t", "nlat", "nlon" /))
      filevarattdef(fout, var_names(var_ind), basis_function)
      var_ind = var_ind + 1
   end do

   do n = 0, overflow_ent_basis_count-1
      var_names(var_ind) = "IRF_OVF_ENT_"+sprinti("%0.2i",n+1)
      filevardef(fout, var_names(var_ind), "double", (/ "z_t", "nlat", "nlon" /))
      filevarattdef(fout, var_names(var_ind), basis_function)
      var_ind = var_ind + 1
   end do

   ;
   ; write variable names to output file
   ;

   if ( False ) then
      nchar = max(strlen(var_names))
      var_names_out = new((/ total_basis_count, nchar /), character)
      var_names_out!0 = "impulse_dim"
      var_names_out!1 = "nchar"

      var_names_out = tochar(" ")

      do n = 0, total_basis_count-1
         tmp = tochar(var_names(n))
         var_names_out(n,0:dimsizes(tmp)-1) = (/ tmp /)
         delete(tmp)
      end do
   end if

   if ( True ) then
      nchar = max(strlen(var_names))
      var_names_out = tochar(var_names)
      var_names_out!0 = "impulse_dim"
      var_names_out!1 = "nchar"
   end if

   filedimdef(fout, (/ "nchar", "impulse_dim" /), (/ nchar, total_basis_count /) , (/ False, False /))
   fout->var_names = var_names_out

   ;
   ; construct impulse variables and write them out to output file
   ;

   var_ind = 0

   do k = 1, stencil_width ; index is 1 based
      do j = 1, stencil_width ; index is 1 based
         do i = 1, stencil_width ; index is 1 based
            print("generating "+var_names(var_ind))

            basis_function = land_mask

            ; set basis function on at selected offset points
            do k2 = k, km, stencil_width ; index is 1 based
            do j2 = j, nlat, stencil_width ; index is 1 based
            do i2 = i, nlon, stencil_width ; index is 1 based
               if (k2 .le. KMT(j2-1,i2-1)) then
                  basis_function(k2-1,j2-1,i2-1) = 1.0
               end if
            end do
            end do
            end do

            ; set basis function off in src and ent regions
            do overflow_ind = 0, overflow_cnt-1
               do k2 = src_kmin(overflow_ind), src_kmax(overflow_ind) ; index is 1 based
               do j2 = src_jmin(overflow_ind), src_jmax(overflow_ind) ; index is 1 based
               do i2 = src_imin(overflow_ind), src_imax(overflow_ind) ; index is 1 based
                  if (k2 .le. KMT(j2-1,i2-1)) then
                     basis_function(k2-1,j2-1,i2-1) = 0.0
                  end if
               end do
               end do
               end do
               do k2 = ent_kmin(overflow_ind), ent_kmax(overflow_ind) ; index is 1 based
               do j2 = ent_jmin(overflow_ind), ent_jmax(overflow_ind) ; index is 1 based
               do i2 = ent_imin(overflow_ind), ent_imax(overflow_ind) ; index is 1 based
                  if (k2 .le. KMT(j2-1,i2-1)) then
                     basis_function(k2-1,j2-1,i2-1) = 0.0
                  end if
               end do
               end do
               end do
            end do

            fout->$var_names(var_ind)$ = basis_function

            var_ind = var_ind + 1
         end do
      end do
   end do

   overflow_impulse_on = new(overflow_cnt, logical)

   delete([/ i, j, k /])
   i = src_imin
   j = src_jmin
   k = src_kmin
   overflow_impulse_on = True
   do n = 0, overflow_src_basis_count-1
      print("generating "+var_names(var_ind))

      basis_function = land_mask

      do overflow_ind = 0, overflow_cnt-1
         if (overflow_impulse_on(overflow_ind)) then
            basis_function(k(overflow_ind)-1,j(overflow_ind)-1,i(overflow_ind)-1) = 1.0
         end if
      end do

      fout->$var_names(var_ind)$ = basis_function

      do overflow_ind = 0, overflow_cnt-1
         i(overflow_ind) = i(overflow_ind) + 1
         if (i(overflow_ind) .gt. src_imax(overflow_ind)) then
            i(overflow_ind) = src_imin(overflow_ind)
            j(overflow_ind) = j(overflow_ind) + 1
            if (j(overflow_ind) .gt. src_jmax(overflow_ind)) then
               j(overflow_ind) = src_jmin(overflow_ind)
               k(overflow_ind) = k(overflow_ind) + 1
               if (k(overflow_ind) .gt. src_kmax(overflow_ind)) then
                  k(overflow_ind) = src_kmin(overflow_ind)
                  overflow_impulse_on(overflow_ind) = False
               end if
            end if
         end if
      end do

      var_ind = var_ind + 1
   end do

   delete([/ i, j, k /])
   i = ent_imin
   j = ent_jmin
   k = ent_kmin
   overflow_impulse_on = True
   do n = 0, overflow_ent_basis_count-1
      print("generating "+var_names(var_ind))

      basis_function = land_mask

      do overflow_ind = 0, overflow_cnt-1
         if (overflow_impulse_on(overflow_ind)) then
            basis_function(k(overflow_ind)-1,j(overflow_ind)-1,i(overflow_ind)-1) = 1.0
         end if
      end do

      fout->$var_names(var_ind)$ = basis_function

      do overflow_ind = 0, overflow_cnt-1
         i(overflow_ind) = i(overflow_ind) + 1
         if (i(overflow_ind) .gt. ent_imax(overflow_ind)) then
            i(overflow_ind) = ent_imin(overflow_ind)
            j(overflow_ind) = j(overflow_ind) + 1
            if (j(overflow_ind) .gt. ent_jmax(overflow_ind)) then
               j(overflow_ind) = ent_jmin(overflow_ind)
               k(overflow_ind) = k(overflow_ind) + 1
               if (k(overflow_ind) .gt. ent_kmax(overflow_ind)) then
                  k(overflow_ind) = ent_kmin(overflow_ind)
                  overflow_impulse_on(overflow_ind) = False
               end if
            end if
         end if
      end do

      var_ind = var_ind + 1
   end do

end
