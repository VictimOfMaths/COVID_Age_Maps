library(shiny)
library(tidyverse)
library(sf)
library(extrafont)
library(paletteer)
library(pals)
library(ragg)
library(patchwork)
library(ggtext)

options(shiny.useragg=TRUE)

server <- function(input, output) {
  
  output$plot <- renderPlot({

ageband <- input$ageband
showplots <- input$showplots

plotdata <- ltlacases %>% filter(age==ageband)

scalemax <- max(abs(plotdata$abschange), na.rm=TRUE)

plot1 <- ggplot()+
  geom_sf(data=Background, aes(geometry=geom), fill="White")+
  geom_sf(data=plotdata, 
          aes(geometry=geom, fill=latest), colour="Black", size=0.1)+
  geom_sf(data=Groups, aes(geometry=geom), fill=NA, colour="Black")+
  geom_sf_text(data=Group_labels, aes(geometry=geom, label=Group.labe,
                                      hjust=just), size=rel(2.4), colour="Black")+
  scale_fill_paletteer_c("pals::ocean.haline", direction=-1,
                         name="Cases per\n100,000", limits=c(0,NA))+
  theme_void()+
  theme(plot.title=element_text(face="bold", size=rel(1.2)),
        text=element_text(family="Lato"))

plot2 <- ggplot()+
  geom_sf(data=Background, aes(geometry=geom), fill="White")+
  geom_sf(data=plotdata, 
          aes(geometry=geom, fill=abschange), colour="Black", size=0.1)+
  geom_sf(data=Groups, aes(geometry=geom), fill=NA, colour="Black")+
  geom_sf_text(data=Group_labels, aes(geometry=geom, label=Group.labe,
                                      hjust=just), size=rel(2.4), colour="Black")+
  scale_fill_paletteer_c("pals::warmcool", 
                         limit=c(-1,1)*scalemax, 
                         name="Change in cases\nper day per 100,000\nin the past week", direction=-1,
                         na.value="transparent")+
  theme_void()+
  theme(plot.title=element_markdown(face="bold", size=rel(1.5)),
        text=element_text(family="Lato"))

if (showplots=="Case rates"){
  p <- plot1+
    labs(title=paste0("COVID-19 case rates in ", ageband, " year-olds in the past week"),
         subtitle=paste0("Rolling 7-day average number of cases in the past week at Lower Tier Local Authority level\nData up to ", maxdate),
         caption="Data from UKHSA, Cartogram from @carlbaker/House of Commons Library\nPlot by @VictimOfMaths")
  
}

if (showplots=="Case rate changes"){
  p <- plot2+
    labs(title=paste0("Changes in COVID-19 case rates in ", ageband, " year-olds in the past week"),
         subtitle=paste0("Change in the past week in the rolling 7-day average number of cases at Lower Tier Local Authority level\nData up to ", maxdate),
         caption="Data from UKHSA, Cartogram from @carlbaker/House of Commons Library\nPlot by @VictimOfMaths")
  
}

if (showplots=="Both"){
  p <- plot1+labs(title=paste0("COVID case rates in ", ageband, 
                               " year-olds and how they have changed in the last week"),
                  subtitle=paste0("Rolling 7-day average number of cases in the past week at Lower Tier Local Authority level\nData up to ", maxdate)) | 
    plot2+labs(caption="Data from UKHSA, Cartogram from @carlbaker/House of Commons Library\nPlot by @VictimOfMaths")
    
}
  
p
  }, height=700)
  
}