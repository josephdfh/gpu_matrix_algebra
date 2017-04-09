A = c(1,2,3,4)
B = c(2,3)
`%*%` <- function(A, B){
    dyn.load('mmult.dll')
    m = nrow(A)
    if(is.null(m)) m = length(A)
    k = nrow(B)
    if(is.null(k)){
        k = length(B)
        n = 1L
    }else{
        n = ncol(B)
    }
    C = .C('mmult', A,B,double(m*n),as.integer(m),as.integer(k),as.integer(n))[[3]]
    dyn.unload('mmult.dll')
    matrix(C,nrow=m)
}
A = matrix(A, nrow=2)
C = A %*% B
print(A)
print(B)
print(C)
