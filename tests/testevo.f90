program testevo
  use futils, only: linspace
  use photochem, only: EvoAtmosphere, version, dp
  implicit none
  character(:), allocatable :: err
  type(EvoAtmosphere) :: pc
  logical :: success
  integer :: i, j
  real(dp), allocatable :: t_eval(:)
  
  print*,'photochem version == ',trim(version)

  call pc%init("../photochem/data", &
               "../photochem/data/reaction_mechanisms/zahnle_earth.yaml", &
               "../tests/testevo_settings.yaml", &
               "../templates/ModernEarth/Sun_now.txt", &
               "../templates/ModernEarth/atmosphere_ModernEarth.txt", &
               err)
  if (allocated(err)) then
    print*,trim(err)
    stop 1
  endif

  ! Just take 3 steps
  pc%var%mxsteps = 3

  allocate(t_eval(100))
  call linspace(5.0_dp, 17.0_dp, t_eval)
  t_eval = 10.0_dp**t_eval

  success = pc%evolve('testevo.dat', 0.0_dp, pc%var%usol_init, t_eval, .true., err)
  if (allocated(err)) then
    print*,trim(err)
    stop 1
  endif

  deallocate(t_eval)

end program