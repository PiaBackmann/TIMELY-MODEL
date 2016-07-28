library(ggplot2)
library(grid)
#read data from GA

picture.path <- "/home/pixi/Desktop/Projekte/Time_delay/Modell/Genetic algorithm/Bilder/film/"
data.path <- "/home/pixi/Desktop/Projekte/Time_delay/Modell/Genetic algorithm/Data/"

numGen = 300
numLarva_v= c(100, 300, 500)
seed = 1
seed_vec<- seq(from=1, to=100)
#genvector<-c(300)

genvector <- c( seq(from = 3, by = 2, to = 20))
meine.farben <- c("0" ="black", "100"="yellow3", "200" ="green", "300"= "cyan","350" = "blue", "400" = "mediumpurple", "500" = "violetred", "1000" = "#0072B2")

tauplotData<-data.frame(generation=NA, tau=NA, seed=NA, larva=NA)

for(i in genvector)
{ 
  for (seed in seed_vec)
  {
    for(numLarva in numLarva_v)
    {
      generationfile = paste0(data.path,"MyOwnGA_generations_larvae_",numLarva,"_seed", seed) 
      
      tau.matrix2 <- read.table(file = generationfile, header = TRUE, sep = " ")
      tau.matrix<-data.matrix(frame=tau.matrix2)
      #############################
      
      tauvector <- tau.matrix[i,]
      neu <- data.frame(generation = i, tau = tauvector, seed = seed, larva=numLarva)
      tauplotData<-rbind(tauplotData, neu)
    }
  }
  
  tauplotData<- na.omit(tauplotData)
  attach(tauplotData)
  
  tauplotDatax <- tauplotData[ which(tauplotData$generation == i),]
  zahl = as.character(i)
  if( i < 100 && i >9)
  {
    zahl = paste0("0",zahl)
  }
  if( i < 10)
  {
    zahl = paste0("00",zahl)
  }
  
  print(zahl)
  filename=paste(picture.path, "Histogram_gen_",zahl,".png", sep="")
  #  print(filename)
  #  png(filename)
  plot.new()
  density <- ggplot(tauplotDatax, aes(tau, fill=as.factor(larva))) + geom_density(alpha = 0.2)
  density <- density + xlab(expression(tau)) + ylab("Density") + theme_bw()
  density <- density + scale_fill_manual(values=meine.farben) 
  # make description of axes bigger and thus more readable
  density <- density + theme(axis.text.x = element_text(size = rel(1.3)))
  density <- density + theme(axis.text.y = element_text(size = rel(1.3)))
  density <- density + theme(axis.title.x  = element_text(size = rel(1.5), vjust = -1))
  density <- density + theme(axis.title.y  = element_text(size = rel(1.3), vjust = 1)) + labs(fill = "Larvae")
  density <- density +  scale_x_continuous(breaks=seq(from = 0, by = 6, to = 60), labels=c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"))
  density <- density + theme(legend.position = "top") 
  density <- density + scale_fill_manual(values=meine.farben, breaks = c("100","300", "500"),
                                                                            labels = c( "100  ","300  ", "500  ")) 
  density <- density + ylim(0, 0.06) #+ annotate(geom="text", x=3, y=0.039, label="100 larvae",
                                            #     color="yellow3", size = 5)
 # density <- density  + annotate(geom="text", x=28, y=0.039, label="300 larvae",
           #                                      color="cyan", size = 5)
#  density <- density  + annotate(geom="text", x=38, y=0.057, label="500 larvae",
                             #    color="violetred", size = 5)
  density <- density  + theme(legend.text  = element_text(size = rel(1.0))) 
  density <- density  + theme(legend.title  = element_text(size = rel(1.0)))
  density <- density + theme(legend.text=element_text(lineheight=1.1),legend.key.height=unit(0.6, "cm")) 

  ggsave(filename=filename)
  density
}

