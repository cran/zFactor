#' Hall-Yarborough correlation
#'
#' @rdname Hall-Yarborough
#' @param pres.pr pseudo-reduced pressure
#' @param temp.pr pseudo-reduced temperature
#' @param tolerance controls the iteration accuracy
#' @param verbose print internal
#' @export
#' @examples
#' # get z value from a Tpr at Ppr
#' z.HallYarborough(pres.pr = 1.5, temp.pr = 2.0)
#' z.HallYarborough(pres.pr = 1.5, temp.pr = 1.1)
#'
#' # for two given Tpr and Ppr vectors, find the calculated z points
#' ppr <- c(0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5)
#' tpr <- c(1.3, 1.5, 1.7, 2)
#' hy <- z.HallYarborough(pres.pr = ppr, temp.pr = tpr)
#' print(hy)
z.HallYarborough <- function(pres.pr, temp.pr, tolerance = 1E-13,
                             verbose = FALSE) {

    co <- sapply(pres.pr, function(x)
        sapply(temp.pr, function(y)
            .z.HallYarborough(pres.pr = x, temp.pr = y,
                            tolerance = tolerance, verbose = verbose)))

    if (length(pres.pr) > 1 || length(temp.pr) > 1) {
        co <- matrix(co, nrow = length(temp.pr), ncol = length(pres.pr))
        rownames(co) <- temp.pr
        colnames(co) <- pres.pr
    }
    return(co)
}



.z.HallYarborough <- function(pres.pr, temp.pr, tolerance = 1E-13,
                             verbose = FALSE) {
    # Hall-Yarborough correlation modified to use the Newton-Raphson method

    F <- function(y) {
        - A * pres.pr + (y + y^2 + y^3 - y^4) / (1 - y)^3  - B * y^2 + C * y^D
    }

    Fprime <- function(y) {
        (1 + 4 * y + 4 * y^2 - 4 * y^3 + y^4 ) / (1 - y)^4 - 2 * B * y + C * D * y^(D-1)
    }

    t <- 1 / temp.pr
    A <- 0.06125 * t * exp(-1.2 * (1 - t)^2)
    B <- t * (14.76 - 9.76 * t + 4.58 * t^2)
    C <- t * (90.7 - 242.2 * t + 42.4 * t^2)
    D <- 2.18 + 2.82 * t

    # first guess for y
    yk0 <- 0.0125 * pres.pr * t * exp(-1.2 * (1 - t)^2)
    yk <- yk0
    delta <- 1
    i <- 1    # itertations

    while (TRUE) {
        try(absFyk <- abs(F(yk)), silent = TRUE)
        if (is.na(absFyk)) {
            yk <- yk0 + 0.1
            # cat(sprintf("%12f \n", absFyk))
        } else if (abs(F(yk)) < tolerance) {
            break
        } else if (is.na(yk)) {
            # yk <- yk0 + 0.1
            stop("yk is NA")
        } else {
            yk0 <- yk
        }

        # if (abs(E(yk)) < tolerance) break
        yk1 <- yk - F(yk) / Fprime(yk)
        delta <- abs(yk - yk1)
        if (verbose)
            cat(sprintf("%3d %12f %12f %14.3f %18.3f %18.3f %18.3f \n", i, pres.pr,
                        delta, yk, F(yk), Fprime(yk), absFyk) )
        yk <- yk1
        i <- i + 1
    }
    if (verbose) cat("\n")
    y <- yk
    z <- A * pres.pr / y
    if (verbose) print(z)
    return(z)
}


# # calculate z values at lower values of Tpr
# library(zFactor)
#
# hy2 <- sapply(ppr2, function(x)
#     sapply(tpr2, function(y) z.HallYarborough(pres.pr = x, temp.pr = y)))
#
# rownames(hy2) <- tpr2
# colnames(hy2) <- ppr2
# print(hy2)