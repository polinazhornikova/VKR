
pgram_bio <- function(x,n) {
  
  N <- nrow(x[[1]])
  M <- ncol(x[[1]])
  
  X <- list()
  
  for (i in 1:n){
    y <- x[[i]]
    NN <- dim(y)
    
    idx1 <- c()
    
    for (k in (1:NN[1])){
      if (sum(is.na(y[k,])) == NN[2]) {
        idx1 <- c(idx1,k)
      }
    }
    
    idx2 <- c()
    for (k in (1:NN[2])){
      if (sum(is.na(y[,k])) == NN[1]) {
        idx2 <- c(idx2,k)
      }
    }
    
    y <- y[-idx1,-idx2]
    NN <- dim(y)
    
    idx2 <- c()
    for (k in (1:NN[2])){
      if (sum(is.na(y[,k])) > 0) {
        idx2 <- c(idx2,k)
      }
    }
    
    if (!is.null(idx2)) {y <- y[,-idx2]}
    NN <- dim(y)
    
    idx1 <- c()
    for (k in (1:NN[1])){
      if (sum(is.na(y[k,])) > 0) {
        idx1 <- c(idx1,k)
      }
    }
    
    if (!is.null(idx1)) {y <- y[-idx1,]}
    NN <- dim(y)
    
    shift.exp <- exp(2i * pi * floor(NN/2) / NN)
    shift1 <- shift.exp[1]^(0:(NN[1] - 1))
    shift2 <- shift.exp[2]^(0:(NN[2] - 1))
    X[[i]] <- Mod(t(mvfft(t(mvfft(outer(shift1, shift2) * y)))))
    
    N <- nrow(y)
    M <- ncol(y)
  }
  
  spec <- list()
  
  for (i in 1:n){
    spec[[i]] <- X[[i]]
  }
  
  freq1 <- seq(-0.5, 0.5, length.out = N) 
  freq2 <- seq(-0.5, 0.5, length.out = M)
  
  list(spec = spec, freq1 = freq1, freq2 = freq2)
}

grouping.auto.pgram.2d.ssa_my_bio <- function(x, groups,
                                          freq.bins1 = 0.1,
                                          freq.bins2 = 0.1,
                                          threshold = 0.8) {
  

  if (missing(groups))
    groups <- as.list(1:min(nsigma(x), nu(x)))
  
  groups <- sort(unique(unlist(groups)))
  n <- length(groups)
  
  Fs <- reconstruct(x, groups = as.list(groups))
  
  pgs <- pgram_bio(Fs, n=n)
  
  freq1.lower.bound <- 0
  freq1.upper.bound <- freq.bins1
  
  freq2.lower.bound <- 0
  freq2.upper.bound <- freq.bins2
  
  norms <- numeric(n)
  
  for (i in (1:n)){
    norms[i] <- sum(pgs$spec[[i]])
  }
  
  contributions <- numeric(n)
  
  for (k in 1:n){
    mm <- pgs$spec[[k]]
    contributions[k] <- sum(mm[abs(pgs$freq1) < freq1.upper.bound, abs(pgs$freq2) < freq2.upper.bound]) / norms[k]
  }  
  
  result <- groups[contributions >= threshold]
  list(g=as.vector(na.omit(result)),contr=contributions)
}

