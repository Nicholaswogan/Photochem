module evoatmosphere_wrapper
  use photochem, only: EvoAtmosphere, err_len, str_len
  use wrapper_utils, only: copy_string_ftoc, copy_string_ctof, len_cstring
  use iso_c_binding
  implicit none
  
contains
  
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !!! allocator and destroyer !!!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  subroutine allocate_evoatmosphere(ptr) bind(c)
    type(c_ptr), intent(out) :: ptr
    type(EvoAtmosphere), pointer :: pc
    allocate(pc)
    ptr = c_loc(pc)
  end subroutine
  
  subroutine deallocate_evoatmosphere(ptr) bind(c)
    type(c_ptr), intent(in) :: ptr
    type(EvoAtmosphere), pointer :: pc
    character(:), allocatable :: err_f
    
    call c_f_pointer(ptr, pc)
    deallocate(pc)
  end subroutine
  
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !!! subroutine wrappers  !!!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  subroutine evoatmosphere_init_wrapper(ptr, data_dir, mechanism_file, &
                                        settings_file, flux_file, &
                                        atmosphere_txt, dat_ptr, &
                                        var_ptr, wrk_ptr , err) bind(c)
    type(c_ptr), intent(in) :: ptr
    character(kind=c_char), intent(in) :: data_dir(*)
    character(kind=c_char), intent(in) :: mechanism_file(*)
    character(kind=c_char), intent(in) :: settings_file(*)
    character(kind=c_char), intent(in) :: flux_file(*)
    character(kind=c_char), intent(in) :: atmosphere_txt(*)
    type(c_ptr), intent(out) :: dat_ptr, var_ptr, wrk_ptr
    character(kind=c_char), intent(out) :: err(err_len+1)
    
    character(len=:), allocatable :: data_dir_f
    character(len=:), allocatable :: mechanism_file_f
    character(len=:), allocatable :: settings_file_f
    character(len=:), allocatable :: flux_file_f
    character(len=:), allocatable :: atmosphere_txt_f
    character(:), allocatable :: err_f
    type(EvoAtmosphere), pointer :: pc
    
    call c_f_pointer(ptr, pc)
    
    allocate(character(len=len_cstring(data_dir))::data_dir_f)
    allocate(character(len=len_cstring(mechanism_file))::mechanism_file_f)
    allocate(character(len=len_cstring(settings_file))::settings_file_f)
    allocate(character(len=len_cstring(flux_file))::flux_file_f)
    allocate(character(len=len_cstring(atmosphere_txt))::atmosphere_txt_f)
    
    call copy_string_ctof(data_dir, data_dir_f)
    call copy_string_ctof(mechanism_file, mechanism_file_f)
    call copy_string_ctof(settings_file, settings_file_f)
    call copy_string_ctof(flux_file, flux_file_f)
    call copy_string_ctof(atmosphere_txt, atmosphere_txt_f)
    
    call pc%init(data_dir_f, &
                 mechanism_file_f, &
                 settings_file_f, &
                 flux_file_f, &
                 atmosphere_txt_f, &
                 err_f)
    
    err(1) = c_null_char
    if (allocated(err_f)) then
      call copy_string_ftoc(err_f, err)
    endif
    dat_ptr = c_loc(pc%dat)
    var_ptr = c_loc(pc%var)
    wrk_ptr = c_loc(pc%wrk) 
  end subroutine

  subroutine evoatmosphere_regrid_prep_atmosphere_wrapper(ptr, nq, nz, usol, top_atmos, err) bind(c)
    type(c_ptr), intent(in) :: ptr
    integer(c_int), intent(in) :: nq, nz
    real(c_double), intent(in) :: usol(nq, nz)
    real(c_double), intent(in) :: top_atmos
    character(kind=c_char), intent(out) :: err(err_len+1)
    
    character(:), allocatable :: err_f
    type(EvoAtmosphere), pointer :: pc
    
    call c_f_pointer(ptr, pc)
    
    call pc%regrid_prep_atmosphere(usol, top_atmos, err_f)
    err(1) = c_null_char
    if (allocated(err_f)) then
      call copy_string_ftoc(err_f, err)
    endif
  end subroutine
  
  subroutine evoatmosphere_evolve_wrapper(ptr, filename, tstart, nq, nz, usol, nt, t_eval, overwrite, restart_from_file, &
                                          success, err) bind(c)
    type(c_ptr), intent(in) :: ptr
    character(kind=c_char), intent(in) :: filename(*)
    real(c_double), intent(inout) :: tstart
    integer(c_int), intent(in) :: nq, nz
    real(c_double), intent(inout) :: usol(nq, nz)
    integer(c_int), intent(in) :: nt
    real(c_double), intent(in) :: t_eval(nt)
    logical(c_bool), intent(in) :: overwrite
    logical(c_bool), intent(in) :: restart_from_file
    logical(c_bool), intent(out) :: success
    character(kind=c_char), intent(out) :: err(err_len+1)
    
    logical :: overwrite_f, success_f, restart_from_file_f
    character(len=:), allocatable :: filename_f
    character(:), allocatable :: err_f
    type(EvoAtmosphere), pointer :: pc
    
    call c_f_pointer(ptr, pc)
    
    allocate(character(len=len_cstring(filename))::filename_f)
    call copy_string_ctof(filename, filename_f)
    overwrite_f = overwrite
    restart_from_file_f = restart_from_file
    
    success_f = pc%evolve(filename_f, tstart, usol, t_eval, overwrite=overwrite_f, &
                          restart_from_file=restart_from_file_f, err=err_f)
    success = success_f
    err(1) = c_null_char
    if (allocated(err_f)) then
      call copy_string_ftoc(err_f, err)
    endif
  end subroutine

  !!!!!!!!!!!!!!!!!!!!!!!!!!!
  !!! getters and setters !!!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!

  subroutine evoatmosphere_t_surf_get(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(out) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    val = pc%T_surf
  end subroutine
  
  subroutine evoatmosphere_t_trop_get(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(out) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    val = pc%T_trop
  end subroutine

  subroutine evoatmosphere_t_trop_set(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(in) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    pc%T_trop = val
  end subroutine
  
  subroutine evoatmosphere_p_top_min_get(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(out) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    val = pc%P_top_min
  end subroutine

  subroutine evoatmosphere_p_top_min_set(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(in) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    pc%P_top_min = val
  end subroutine

  subroutine evoatmosphere_p_top_max_get(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(out) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    val = pc%P_top_max
  end subroutine

  subroutine evoatmosphere_p_top_max_set(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(in) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    pc%P_top_max = val
  end subroutine

  subroutine evoatmosphere_top_atmos_adjust_frac_get(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(out) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    val = pc%top_atmos_adjust_frac
  end subroutine

  subroutine evoatmosphere_top_atmos_adjust_frac_set(ptr, val) bind(c)
    type(c_ptr), intent(in) :: ptr
    real(c_double), intent(in) :: val
    type(EvoAtmosphere), pointer :: pc
    call c_f_pointer(ptr, pc)
    pc%top_atmos_adjust_frac = val
  end subroutine

end module