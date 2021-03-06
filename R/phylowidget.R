#' phylowidget Phylogeny widget
#'
#' An interactive phylogeny viewer using D3.js, based on phylotree.js. Just supply
#' a \code{Newick} string or \code{phylo} data as the parameter.
#' 
#' @param nwk Newick string or \code{phylo} from the \code{\link[ape]{ape}} package.
#' @param width Integer in px to override the default width. The default width fills the browser window.
#' @param height Integer in px to override the default height. The default height fills the browser window.
#' 
#' @note
#' This displays a phylogeny in a browser window; by default, the viewer is disabled.
#' 
#' @references
#' \code{phylotree.js} \url{http://github.com/veg/phylotree.js}
#' 
#' @examples
#' \dontrun{
#' # A stand-alone example
#' library(ape)
#' data(bird.orders)
#' phylowidget(bird.orders)
#' }
#' 
#' @import htmlwidgets
#' @export
phylowidget <- function(nwk, width = NULL, height = NULL) {

  # try to convert if not character (assuming not Newick)
  if(class(nwk) %in% c("phylo","multiPhylo")){
    warning( "attempting conversion to Newick format", call. = F)
    if (requireNamespace("ape")) {
      nwk = ape::write.tree( nwk )
    } else {
      stop("If input is not a Newick string, phylowidget requires ape package.  Please install ape.")
    }
  }

  # forward options using x
  x = list(
    nwk=nwk
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'phylowidget',
    x,
    width = width,
    height = height,
    sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress = TRUE,
                                             browser.fill = TRUE,
                                             browser.padding = 0),
    package = 'phylowidget'
  )
}

#' phylowidgetOutput Helper function for phyloshiny
#' @param outputId The output identifier.
#' @param width The width of the device.
#' @param height The height of the device.
#' 
#' @seealso renderPhylowidget
#' @export
phylowidgetOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'phylowidget', width, height, package = 'phylowidget')
}

#' renderPhylowidget Helper function for phyloshiny
#' @param expr The function to be rendered
#' @param env The environment for rendering.
#' @param quoted Should the output be quoted?
#' 
#' @seealso phylowidgetOutput
#' @export
renderPhylowidget <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, phylowidgetOutput, env, quoted = TRUE)
}

#' phyloshiny A phylowidget as a Shiny app
#' @param nwk Either a Newick string or a \code{phylo} or \code{multiPhylo} object.
#' 
#' @examples
#' \dontrun{
#' library(ape)
#' data(bird.orders)
#' phyloshiny(bird.orders)
#' }
#' 
#' @seealso phylowidget
#' @export
phyloshiny <- function(nwk) {
  require(shiny)
  shinyApp(
    ui = fluidPage(
      phylowidgetOutput("phylowidget")
    ), 
    server = function(input, output) {
      output$phylowidget <- renderPhylowidget(
        phylowidget(nwk)
      )
      observe({
      if(is.null(input$close)){
        return()
      }
      else{
        if (input$close>0){
          tree <<- input$tree
          print(tree)
          stopApp()
        }
      }
      })
    }
  )
}
