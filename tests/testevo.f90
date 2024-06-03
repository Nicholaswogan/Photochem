program main
  implicit none
  call main_()
contains

  subroutine main_()
    use photochem, only: EvoAtmosphere, version, dp
    character(:), allocatable :: err
    type(EvoAtmosphere) :: pc
    integer :: ind
    real(dp) :: tn
    logical :: converged

    ! Print version
    print*,'photochem version == ',trim(version)

    ! Initialize code
    pc = EvoAtmosphere("../photochem/data/reaction_mechanisms/zahnle_earth.yaml", &
                      "../examples/ModernEarth/settings.yaml", &
                      "../examples/ModernEarth/Sun_now.txt", &
                      "../examples/ModernEarth/atmosphere.txt", &
                      "../photochem/data", &
                      err)
    if (allocated(err)) then
      print*,trim(err)
      stop 1
    endif

    ! Change RH to 0.5.
    ind = findloc(pc%dat%species_names, 'H2Oaer', 1)
    pc%var%cond_params(ind)%RHc = 0.5_dp

    ! Initialize stepper
    call pc%initialize_stepper(pc%var%usol_init, err)
    if (allocated(err)) then
      print*,trim(err)
      stop 1
    endif

    ! Integrate to photochemical equilibrium
    do
      tn = pc%step(err)
      if (allocated(err)) then
        print*,trim(err)
        stop 1
      endif
      converged = pc%check_for_convergence(err)
      if (allocated(err)) then
        print*,trim(err)
        stop 1
      endif
      if (converged) exit
    enddo

    ! Destroy stepper
    call pc%destroy_stepper(err)
    if (allocated(err)) then
      print*,trim(err)
      stop 1
    endif

  end subroutine

end program