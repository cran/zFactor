# Beggs and Brill

#' Beggs and Brill correlation
#'
#' Calculate the Z factor with the Brill-Beggs correlation
#'
#' @param pres.pr pseudo-reduced pressure
#' @param temp.pr pseudo-reduced temperature
#' @param tolerance rounding tolerance to avoid rounding readings that are in
#' the middle of the grid. "tolerance" adds flexibility in deciding point closeness.
#' @param verbose print internal
#' @rdname Beggs-Brill
#' @export
#' @examples
#' ## one single z calculation
#' z.BeggsBrill(pres.pr = 1.5, temp.pr = 2.0)
#' ## calculate z for multiple values of Tpr and Ppr
#' ppr <- c(0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5)
#' tpr <- c(1.3, 1.5, 1.7, 2)
#' z.BeggsBrill(pres.pr = ppr, temp.pr = tpr)
z.BeggsBrill <- function(pres.pr, temp.pr,
                         tolerance = 1e-13, verbose = FALSE) {
    # calls the core function.
    # this function converts the results to a matrix
    co <- sapply(pres.pr, function(x)
        sapply(temp.pr, function(y)
            .z.BeggsBrill(pres.pr = x, temp.pr = y,
                                      tolerance = tolerance, verbose = verbose)))
    if (length(pres.pr) > 1 || length(temp.pr) > 1) {
        co <- matrix(co, nrow = length(temp.pr), ncol = length(pres.pr))
        rownames(co) <- temp.pr
        colnames(co) <- pres.pr
    }
    return(co)
}


.z.BeggsBrill <- function(pres.pr, temp.pr,
                          tolerance = 1e-13, verbose = FALSE) {
    # core function
    # Brill and Beggs compressibility factor (1973)

    A <- 1.39 *(temp.pr - 0.92)^0.5 - 0.36 * temp.pr - 0.101

    zF <-(0.3016 - 0.49 * temp.pr + 0.1824 * temp.pr^2)
    B <- (0.62 - 0.23 * temp.pr) * pres.pr +
        (0.066 / (temp.pr - 0.86) - 0.037) * pres.pr^2 +
        0.32 * pres.pr^6 / 10^(9 * (temp.pr - 1))
    C <- 0.132 - 0.32 * log10(temp.pr)
    D <- 10^(0.3106 - 0.49 * temp.pr + 0.1824 * temp.pr^2)

    z <- A + (1 - A) / exp(B) + C * pres.pr^D

    return(z)
}
