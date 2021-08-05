
module interp_tools
  implicit none
  
  integer, parameter, private :: real_kind = kind(1.d0)

contains
  
  ! binning.f90 is same as binning.f 
  ! adding to module means explicit interface to function
  ! which allows for more compiler errors to be caught
  include "binning.f90"

  ! 1D linear interpolation with constant extrapolation.
  subroutine interp(ng, n, xg, x, y, yg, err)
    implicit none
    integer, intent(in) :: ng ! length of new grid (we interpolate to this new grid)
    integer, intent(in) :: n ! length of old grid
    real(real_kind), intent(in) :: xg(ng) ! new grid
    real(real_kind), intent(in) :: x(n), y(n) ! old data
    
    real(real_kind), intent(out) :: yg(ng) ! new data 
    character(len=100), intent(out) :: err 
    
    real(real_kind) :: slope
    integer :: i, j, nn
    
    do i = 1,n-1
      if (x(i+1) <= x(i)) then
        err = 'x must be sorted.'
        return
      endif
    enddo
    do i = 1,ng-1
      if (xg(i+1) <= xg(i)) then
        err = 'xg must be sorted.'
        return
      endif
    enddo
    
    nn = 1
    do i = 1,ng
      if (xg(i) < x(1)) then
        yg(i) = y(1)
      elseif ((xg(i) >= x(1)) .and. (xg(i) <= x(n))) then
        do j = nn,n
          if ((xg(i) >= x(j)) .and. (xg(i) <= x(j+1))) then
            slope = (y(j+1)-y(j))/(x(j+1)-x(j))
            yg(i) = y(j) + slope*(xg(i)-x(j))
            nn = j
            exit
          endif
        enddo
      elseif (xg(i) > x(n)) then
        yg(i) = y(n)
      endif
    enddo
    
  end subroutine
  
end module