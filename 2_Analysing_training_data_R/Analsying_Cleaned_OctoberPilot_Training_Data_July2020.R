######################################################################################################################
### October Pilot training data analysis  - July 2020
######################################################################################################################
# Date: 09/07/2020
# Author: Claire R. Smid

# paper to follow
# https://www.jneurosci.org/content/34/1/149
# multilevel model specification: http://www.rensenieuwenhuis.nl/r-sessions-16-multilevel-model-specification-lme4/
# multivariate analysis: https://mac-theobio.github.io/QMEE/MultivariateMixed.html

# This analysis will:
# - work with the cleaned training data from the Matlab scripts
# - make the graphs as they are in the paper
# - run the mixed models as they are reported in the paper.

# things to do in this script

# 1 - make graphs
# 2. some basic stats:
#   2.1 - compare first - last training sessions. correlate this with pre-post changes
#   2.2 - check number of sessions (per participant per group?)
#   2.3 - how many bonus games completed?
# 3. mixed models


# clears workspace
rm(list=ls())

# get necessary packages
library(ggplot2)
library(lattice)
library(reshape2)
library(ggrepel)
# install.packages("ggrepel")
# install.packages("tidyr")
library(corrplot)
library(ggcorrplot)
library(dplyr)
library(tidyr)
library(rlang)

library(dplyr) 

# install.packages("cowplot")
library(gridExtra)
library(cowplot)

# remove.packages('lattice')
# 
# install.packages('lattice')

library(Rmisc)

# import packages
library(lme4)
library(mlmRev)

#install.packages('psych')
library(psych)


#install.packages("extrafont")
library(extrafont)
#font_import()
loadfonts(device="win")       #Register fonts for Windows bitmap output
#loadfonts(device="pdf")       #Register fonts for Windows bitmap output
fonts()           


###############################################################################################
### 9 July 2020 ---- IMPORT TRAINING DATA
# import data (new method of cleaning - logged in Matlab files)

## EXPERIMENTAL
Exp_train <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/1_CleaningData_CalculatingSSRT_Matlab/Clean_EXP_SSRT_V1.csv')
#Exp_train2 <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/1_CleaningData_CalculatingSSRT_Matlab/Clean_EXP_SSRT_V2.csv')

Exp_train_2PP <-Exp_train[!(Exp_train$Inc_session>8),]


# define groups / factors
Exp_train_2PP <- within(Exp_train_2PP,{
  Participant <- as.factor(Participant)
  #Inc_session <- as.factor(Inc_session)
})

# define groups / factors
Exp_train <- within(Exp_train,{
  Participant <- as.factor(Participant)
  #Inc_session <- as.factor(Inc_session)
})

Exp_train <- data.frame(Exp_train)

# # define groups / factors
# Exp_train2 <- within(Exp_train2,{
#   Participant <- as.factor(Participant)
#   Inc_session <- as.factor(Inc_session)
# })
# 
# Exp_train2 <- data.frame(Exp_train2)
# 
# # remove session 15 because only one game from one particiapnt, cant get SD from this
# Exp_train2 = Exp_train2[!Exp_train2$Inc_session == 15,]

### ACTION SELECT
#Act_train <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/1_CleaningData_CalculatingSSRT_Matlab/Clean_ACT_SSRT2.csv')
Act_train <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/1_CleaningData_CalculatingSSRT_Matlab/Clean_ACT_SSRT_V1.csv')

# define groups / factors
Act_train <- within(Act_train,{
  Participant <- as.factor(Participant)
  #Inc_session <- as.factor(Inc_session)
})

#Act_train[Act_train == "NaN"] <- NA

Act_train <- data.frame(Act_train)



### CONTROL
Con_train <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/1_CleaningData_CalculatingSSRT_Matlab/Clean_CON_RTs_V1.csv')

# define groups / factors
Con_train <- within(Con_train,{
  Participant <- as.factor(Participant)
 # Inc_session <- as.factor(Inc_session)
})

Con_train <- data.frame(Con_train)

### 1. G R A P H S


# theme_classic() <-   theme_classic()




cbp1 <- c("#999999", "#E69F00", "#56B4E9")


#### ------------------------------------------------------------------------------------- ###
#############################  1 . 1  E X P E R I M E N T A L  ###############################

# ########################################### SSRT 1 Mean plot
# # create means per session over the games
# Exp_M <- summarySE(data = Exp_train, measurevar = "mean_SSRT1", groupvars = c("Inc_session"))
# 
# Exp_M$Inc_session <- as.numeric(Exp_M$Inc_session)
# 
# 
# ### plot for the mean values over session, rather than per ID
# ggplot(data = Exp_M, aes(x = Inc_session, y = mean_SSRT1)) +
#   stat_smooth(data = Exp_M, aes(x = Inc_session, y = mean_SSRT1),size = 1, alpha = 0.4,
#               color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
#   geom_point(data = Exp_M, aes(x = Inc_session, y = mean_SSRT1),size = 3, shape = 21) +
#   #geom_line(stat="identity") +
#   guides(color = FALSE) +
#   scale_y_continuous(breaks = seq(0,350,50),lim = c(0,350)) +
#   #coord_cartesian(ylim = c(0,600)) +
#   scale_x_continuous(breaks = seq(1,8,1), lim = c(1,8)) +
#   ggtitle('Mean SSRT per session for the\nresponse inbibition group') +
#   xlab('Sessions') +
#   ylab('SSRT (ms)') +
#   theme_light() +
#   theme(
#     #legend.position = "none",
#     text = element_text(family="Garamond", size=12), 
#     plot.title = element_text(color="black", size=24 ,hjust = 0.5,margin=margin(0,0,10,0)),
#     legend.title = element_blank(),
#     legend.text = element_text(size = 16),
#     axis.title.y = element_text(color="black", size=18),
#     axis.title.x = element_text(color="black", size=18, margin=margin(5,0,0,0)),
#     axis.text.x = element_text(size = 16, margin=margin(5,0,0,0)),
#     axis.text.y = element_text(size = 16, margin=margin(0,5,0,10))
#   )
# 
# # Saving plots with fixed dimensions, quality etc.
# ggsave("Exp_SSRT1_Mean.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
#        scale = 1, width = 20, height = 16, units = "cm",
#        dpi = 300)



########################################### 
########################################### SSRT 1 WITH INDIVIDUAL TIME LINES OVERLAY
# create means per session over the games

Exp_M <- summarySE(data = Exp_train, measurevar = "mean_SSRT1", groupvars = c("Inc_session"))
Exp_ID <- summarySE(data = Exp_train, measurevar = "mean_SSRT1", groupvars = c("Participant","Inc_session"))

Exp_M$Inc_session <- as.numeric(Exp_M$Inc_session)
Exp_ID$Inc_session <- as.numeric(Exp_ID$Inc_session)


### plot for the mean values over session, rather than per ID
EXP_SSRT <- ggplot(data = Exp_M, aes(x = Inc_session, y = mean_SSRT1)) +
  geom_line(data = Exp_ID, aes(x = Inc_session, y = mean_SSRT1, 
                               group = Participant,linetype = Participant),colour = 'black',lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Exp_ID, aes(x = Inc_session, y = mean_SSRT1),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Exp_M, aes(x = Inc_session, y = mean_SSRT1),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,1000,250),lim = c(0,1000)) +
  #coord_cartesian(ylim = c(0,600)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  ggtitle('Mean SSRT') +
  #ggtitle('Mean SSRT per session and per participant for the\nresponse inhibition group') +
  xlab('Sessions') +
  ylab('SSRT (ms)') +
  theme_light() +
  theme_classic()

EXP_SSRT

# Saving plots with fixed dimensions, quality etc.
ggsave("Exp_SSRT1_ID_Means.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)



########################################### 
########################################### SSD WITH INDIVIDUAL TIME LINES OVERLAY

# create means per session over the games
Exp_SSD_M <- summarySE(data = Exp_train, measurevar = "mean_SSD", groupvars = c("Inc_session"))
Exp_SSD_ID <- summarySE(data = Exp_train, measurevar = "mean_SSD", groupvars = c("Participant","Inc_session"))

Exp_SSD_M$Inc_session <- as.numeric(Exp_SSD_M$Inc_session)
Exp_SSD_ID$Inc_session <- as.numeric(Exp_SSD_ID$Inc_session)

### plot for the mean values over session, rather than per ID
EXP_SSD <- ggplot(data = Exp_SSD_M, aes(x = Inc_session, y = mean_SSD)) +
  geom_line(data = Exp_SSD_ID, aes(x = Inc_session, y = mean_SSD, 
                               group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Exp_SSD_ID, aes(x = Inc_session, y = mean_SSD),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Exp_SSD_M, aes(x = Inc_session, y = mean_SSD),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(lim = c(0,1000)) +
  #coord_cartesian(ylim = c(0,600)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  ggtitle('Mean SSD') +
  #ggtitle('Mean SSD per session for the\nresponse inhibition group') +
  xlab('Sessions') +
  ylab('SSD (ms)') +
  theme_light() +
  theme_classic()

EXP_SSD  

# Saving plots with fixed dimensions, quality etc.
ggsave("EXP_SSD_M_ID.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


############################### SSRT 1 INDIVIDUAL REGRESSION LINES. COLOR PLOTS
Exp_S_M <- summarySE(data = Exp_train, measurevar = "mean_SSRT1", groupvars = c("Participant","Inc_session"))
Exp_S_M$Inc_session <- as.numeric(Exp_S_M$Inc_session)

#### line plot to show individual linear lines for each participant over session. EXPERIMENTAL
EXP_Reg <- ggplot(data = Exp_S_M, aes(x = Inc_session, y = mean_SSRT1, color = Participant, group = Participant)) +
  stat_smooth(data = Exp_S_M, aes(x = Inc_session, y = mean_SSRT1, color = Participant), 
              size = 1, alpha = 0.05,  linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  #geom_point() +
  #geom_line(y = 0, linetype = "dashed", colour = "black", size = 1) +
  guides(color = FALSE) +
  #coord_cartesian(ylim = c(0,1200)) +
  #scale_x_log10(breaks=c(5, 6, 7, 8, 9, 10, 11, 30)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  scale_y_continuous(breaks = seq(0,1250,250),lim = c(0,1250)) +
  ggtitle('Linear slopes for SSRT') +
  #ggtitle('Linear slopes for SSRT per session for\neach participant') +
  xlab('Sessions') +
  ylab('SSRT (ms)') +
  theme_light() +
  theme_classic()

EXP_Reg

# Saving plots with fixed dimensions, quality etc.
ggsave("EXP_RegSlopes.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


############# Go RT (Standardised)

# create means per session over the games
Exp_RT <- summarySE(data = Exp_train, measurevar = "mean_Corr_goRT", groupvars = c("Inc_session"))
Exp_RT_ID <- summarySE(data = Exp_train, measurevar = "mean_Corr_goRT", groupvars = c("Participant","Inc_session"))

Exp_RT$Inc_session <- as.numeric(Exp_RT$Inc_session)
Exp_RT_ID$Inc_session <- as.numeric(Exp_RT_ID$Inc_session)

### plot for the mean values over session, rather than per ID
EXP_RT_G <- ggplot(data = Exp_RT, aes(x = Inc_session, y = mean_Corr_goRT)) +
  geom_line(data = Exp_RT_ID, aes(x = Inc_session, y = mean_Corr_goRT, 
                                   group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Exp_RT_ID, aes(x = Inc_session, y = mean_Corr_goRT),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Exp_RT, aes(x = Inc_session, y = mean_Corr_goRT),size = 4, stroke = 1, shape = 21) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,1250,250),lim = c(0,1250)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  #coord_cartesian(ylim = c(0,300)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('Mean reaction time for go trials') +
  #ggtitle('Mean reaction time for go trials per session\nfor the response inhibition group') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

EXP_RT_G

# Saving plots with fixed dimensions, quality etc.
ggsave("Exp_RT_M_ID.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)



############# CovVar RT

# create means per session over the games
Exp_RT <- summarySE(data = Exp_train, measurevar = "CovVar_all_goRT", groupvars = c("Inc_session"))
Exp_RT_ID <- summarySE(data = Exp_train, measurevar = "CovVar_all_goRT", groupvars = c("Participant","Inc_session"))

Exp_RT$Inc_session <- as.numeric(Exp_RT$Inc_session)
Exp_RT_ID$Inc_session <- as.numeric(Exp_RT_ID$Inc_session)

### plot for the mean values over session, rather than per ID
EXP_RT_G <- ggplot(data = Exp_RT, aes(x = Inc_session, y = CovVar_all_goRT)) +
  geom_line(data = Exp_RT_ID, aes(x = Inc_session, y = CovVar_all_goRT, 
                                  group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Exp_RT_ID, aes(x = Inc_session, y = CovVar_all_goRT),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Exp_RT, aes(x = Inc_session, y = CovVar_all_goRT),size = 4, stroke = 1, shape = 21) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  #scale_y_continuous(breaks = seq(0,1250,250),lim = c(0,1250)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  #coord_cartesian(ylim = c(0,300)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('RT variability for all trials over sessions') +
  #ggtitle('Mean reaction time for go trials per session\nfor the response inhibition group') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

EXP_RT_G

# Saving plots with fixed dimensions, quality etc.
ggsave("Exp_RT_M_ID.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


############# dprime

# create means per session over the games
Exp_IC <- summarySE(data = Exp_train, measurevar = "dprime", groupvars = c("Inc_session"))
Exp_IC_ID <- summarySE(data = Exp_train, measurevar = "dprime", groupvars = c("Participant","Inc_session"))

Exp_IC$Inc_session <- as.numeric(Exp_IC$Inc_session)
Exp_IC_ID$Inc_session <- as.numeric(Exp_IC_ID$Inc_session)

### plot for the mean values over session, rather than per ID
ggplot(data = Exp_IC, aes(x = Inc_session, y = dprime)) +
  geom_line(data = Exp_IC_ID, aes(x = Inc_session, y = dprime, 
                                  group = Participant),colour = "black",lwd=0.5, alpha = 0.4) +
  stat_smooth(data = Exp_IC_ID, aes(x = Inc_session, y = dprime),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Exp_IC, aes(x = Inc_session, y = dprime),size = 5, stroke = 1, shape = 21) +
  #geom_line(stat="identity") +
  guides(color = FALSE) +
  #scale_y_continuous(breaks = seq(0,100,10),lim = c(0,100)) +
  #coord_cartesian(ylim = c(0,300)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  ggtitle('Mean probability to successfully inhibit per session\nand per participant') +
  #ggtitle('Mean reaction time for go trials per session\nfor the response inhibition group') +
  xlab('Sessions') +
  ylab('Probability') +
  theme_light() +
  theme_classic()

# Saving plots with fixed dimensions, quality etc.
ggsave("Exp_dprime_ID.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


##### combine graphs

title <- ggdraw() + 
  draw_label(
    "Response Inhibition Group",
    fontfamily = "Helvetica",
    fontface = "plain",
    size = 18,
    hjust = 0.5
  )

GG1 <- plot_grid(EXP_SSRT, EXP_SSD, EXP_Reg, EXP_RT_G, 
          align = "h", rel_widths = c(5, 5), ncol =2, labels = "auto")

GG1

plot_grid(
  title, GG1,
  ncol= 1,
  rel_heights = c(0.08,1)
)


# # Saving plots with fixed dimensions, quality etc.
ggsave("EXP_Train_Combo.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 20, units = "cm",
       dpi = 300)








#### ------------------------------------------------------------------------------------- ###
#############################  1 . 2  A C T I O N  S E L E C T  ##############################



###########################################  WITH INDIVIDUAL TIME LINES OVERLAY for action select group
# create means per session over the games
### INSTEAD OF SSRT, let's look at correct RT for action trials??? 
# This is "mean_CorrActSel_RT"

completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}

Act_train_NoNA <-completeFun(Act_train, "mean_CorrActSel_RT") # 5 games had no correct responses, not included here

Act_train

Act_M <- summarySE(data = Act_train, measurevar = "mean_CorrActSel_RT", groupvars = c("Inc_session"))
Act_ID <- summarySE(data = Act_train, measurevar = "mean_CorrActSel_RT", groupvars = c("Participant","Inc_session"))

Act_M$Inc_session <- as.numeric(Act_M$Inc_session)
Act_ID$Inc_session <- as.numeric(Act_ID$Inc_session)



### plot for the mean values over session, rather than per ID
ACT_CRT <- ggplot(data = Act_M, aes(x = Inc_session, y = mean_CorrActSel_RT)) +
  geom_line(data = Act_ID, aes(x = Inc_session, y = mean_CorrActSel_RT, 
                               group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Act_ID, aes(x = Inc_session, y = mean_CorrActSel_RT),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Act_M, aes(x = Inc_session, y = mean_CorrActSel_RT),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,1500,250), lim = c(0,1500)) +
  #coord_cartesian(ylim = c(0,600)) +
  scale_x_continuous(breaks = seq(0,16,2), lim = c(1,15)) +
  ggtitle('Context Monitoring CorrRT') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

ACT_CRT


# Saving plots with fixed dimensions, quality etc.
ggsave("Act_corrRT_ID_M.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)

########################################### 
########################################### SSD WITH INDIVIDUAL TIME LINES OVERLAY

Act_train_NoNA <-completeFun(Act_train, "mean_SSD")

# create means per session over the games
Act_SSD_M <- summarySE(data = Act_train_NoNA, measurevar = "mean_SSD", groupvars = c("Inc_session"))
Act_SSD_ID <- summarySE(data = Act_train_NoNA, measurevar = "mean_SSD", groupvars = c("Participant","Inc_session"))

Act_SSD_M$Inc_session <- as.numeric(Act_SSD_M$Inc_session)
Act_SSD_ID$Inc_session <- as.numeric(Act_SSD_ID$Inc_session)



### plot for the mean values over session, rather than per ID
ACT_SSD<-ggplot(data = Act_SSD_M, aes(x = Inc_session, y = mean_SSD)) +
  geom_line(data = Act_SSD_ID, aes(x = Inc_session, y = mean_SSD, 
                               group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Act_SSD_ID, aes(x = Inc_session, y = mean_SSD),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Act_SSD_M, aes(x = Inc_session, y = mean_SSD),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,1000,250),lim = c(0,1000)) +
  #coord_cartesian(ylim = c(0,600)) +
  scale_x_continuous(breaks = seq(0,16,2), lim = c(1,15)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('Mean SSD') +
  xlab('Sessions') +
  ylab('SSD (ms)') +
  theme_light() +
  theme_classic()

ACT_SSD

# Saving plots with fixed dimensions, quality etc.
ggsave("Act_SSD_M.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)

############################### INDIVIDUAL REGRESSION LINES. COLOR PLOTS

Act_train_NoNA <-completeFun(Act_train, "mean_CorrActSel_RT")

Act_S_M <- summarySE(data = Act_train_NoNA, measurevar = "mean_CorrActSel_RT", groupvars = c("Participant","Inc_session"))

Act_S_M$Inc_session <- as.numeric(Act_S_M$Inc_session)

#### line plot to show individual linear lines for each participant over session. EXPERIMENTAL
ACT_Reg<-ggplot(data = Act_S_M, aes(x = Inc_session, y = mean_CorrActSel_RT, color = Participant, group = Participant)) +
  #scale_x_continuous(breaks = seq(0,20,2), lim = c(1,20)) +
  stat_smooth(data = Act_S_M, aes(x = Inc_session, y = mean_CorrActSel_RT, color = Participant), 
              size = 1, alpha = 0.05,  linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  #geom_point() +
  #geom_line(y = 0, linetype = "dashed", colour = "black", size = 1) +
  guides(color = FALSE) +
  coord_cartesian(ylim = c(0,1500)) +
  #scale_x_log10(breaks=c(5, 6, 7, 8, 9, 10, 11, 30)) +
  scale_x_continuous(breaks = seq(0,16,2), lim = c(1,15)) +
  #scale_y_continuous(breaks = seq(-250,1250,250), lim = c(-250,1250)) +
  ggtitle('Context Monitoring CorrRT Slopes') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

ACT_Reg

# Saving plots with fixed dimensions, quality etc.
ggsave("Act_corrRT_RegSlopes.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


############# No point looking at accuracy since it hovers around 68%, which I think is the same for the SSRT group. 

# # create means per session over the games
# Act_Corr <- summarySE(data = Act_train, measurevar = "dprime", groupvars = c("Inc_session"))
# Act_Corr_ID <- summarySE(data = Act_train, measurevar = "dprime", groupvars = c("Participant","Inc_session"))
# 
# Act_Corr$Inc_session <- as.numeric(Act_Corr$Inc_session)
# Act_Corr_ID$Inc_session <- as.numeric(Act_Corr_ID$Inc_session)
# 
# 
# ### plot for the mean values over session, rather than per ID
# ggplot(data = Act_Corr, aes(x = Inc_session, y = dprime)) +
#   geom_line(data = Act_Corr_ID, aes(x = Inc_session, y = dprime, 
#                                    group = Participant),colour = "black",lwd=0.5, alpha = 0.4) +
#   stat_smooth(data = Act_Corr_ID, aes(x = Inc_session, y = dprime),size = 1, alpha = 0.4,
#               color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
#   geom_point(data = Act_Corr, aes(x = Inc_session, y = dprime),size = 5, stroke = 1, shape = 1) +
#   #geom_line(stat="identity") +
#   guides(color = FALSE) +
#   #scale_y_continuous(breaks = seq(0,1250,250),lim = c(0,1300)) +
#   #coord_cartesian(ylim = c(0,300)) +
#   scale_x_continuous(breaks = seq(1,15,1), lim = c(1,15)) +
#   #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
#   ggtitle('Mean reaction time for go trials per session\nfor the response inhibition group') +
#   xlab('Sessions') +
#   ylab('Reaction time (ms)') +
#   theme_light() +
#   theme_classic()
# 
# # Saving plots with fixed dimensions, quality etc.
# ggsave("Act_dprime.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
#        scale = 1, width = 20, height = 16, units = "cm",
#        dpi = 300)



####################### go trials
Act_goRT <- summarySE(data = Act_train, measurevar = "mean_Corr_go_RT", groupvars = c("Inc_session"))
Act_goRT_ID <- summarySE(data = Act_train, measurevar = "mean_Corr_go_RT", groupvars = c("Participant","Inc_session"))

Act_goRT$Inc_session <- as.numeric(Act_goRT$Inc_session)
Act_goRT_ID$Inc_session <- as.numeric(Act_goRT_ID$Inc_session)

ACT_RT<-ggplot(data = Act_goRT, aes(x = Inc_session, y = mean_Corr_go_RT)) +
  geom_line(data = Act_goRT_ID, aes(x = Inc_session, y = mean_Corr_go_RT, 
                                   group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Act_goRT_ID, aes(x = Inc_session, y = mean_Corr_go_RT),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Act_goRT, aes(x = Inc_session, y = mean_Corr_go_RT),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,1250,250),lim = c(0,1250)) +
  #coord_cartesian(ylim = c(0,600)) +
  scale_x_continuous(breaks = seq(0,16,2), lim = c(1,15)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('Mean correct RT for go trials') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

ACT_RT

# Saving plots with fixed dimensions, quality etc.
ggsave("Act_corrGoRT.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)




##### combine graphs

title <- ggdraw() + 
  draw_label(
    "Context Monitoring Group",
    fontfamily = "Helvetica",
    fontface = "plain",
    size = 18,
    hjust = 0.5
  )


GG2 <- plot_grid(ACT_CRT, ACT_SSD, ACT_Reg, ACT_RT, 
                 align = "h", rel_widths = c(5, 5), ncol =2, labels = "auto")

GG2

plot_grid(
  title, GG2,
  ncol= 1,
  rel_heights = c(0.1,1)
)





# # Saving plots with fixed dimensions, quality etc.
ggsave("ACT_Train_Combo.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 20, units = "cm",
       dpi = 300)












#### ------------------------------------------------------------------------------------- ###
####################################  1. 3  C O N T R O L  ###################################




########################################### GO RT, mean data over session
# create means per session over the games

#remove one game where the 
#Con_Train_2 <-Con_train[!(Con_train$mean_Stim_dur>10000),]

Con_M <- summarySE(data = Con_train, measurevar = "mean_Corr_goRT_2SD", groupvars = c("Inc_session"))
Con_M_ID <- summarySE(data = Con_train, measurevar = "mean_Corr_goRT_2SD", groupvars = c("Participant","Inc_session"))

Con_M$Inc_session <- as.numeric(Con_M$Inc_session)
Con_M_ID$Inc_session <- as.numeric(Con_M_ID$Inc_session)


### plot for the mean values over session, rather than per ID
Con_GoRT<- ggplot(data = Con_M, aes(x = Inc_session, y = mean_Corr_goRT_2SD)) +
  geom_line(data = Con_M_ID, aes(x = Inc_session, y = mean_Corr_goRT_2SD, 
                                    group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Con_M_ID, aes(x = Inc_session, y = mean_Corr_goRT_2SD),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Con_M, aes(x = Inc_session, y = mean_Corr_goRT_2SD),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,1000,250),lim = c(0,1000)) +
  #coord_cartesian(ylim = c(0,300)) +
  scale_x_continuous(breaks = seq(0,20,2), lim = c(1,20)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('Mean correct RT') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

Con_GoRT

# Saving plots with fixed dimensions, quality etc.
ggsave("Con_CorrRTsd.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)



########################################### Stimulus duration WITH INDIVIDUAL TIME LINES OVERLAY for response speed group
# create means per session over the games

Con_Cor <- summarySE(data = Con_train, measurevar = "mean_Stim_dur", groupvars = c("Inc_session"))
Con_Cor_ID <- summarySE(data = Con_train, measurevar = "mean_Stim_dur", groupvars = c("Participant","Inc_session"))

Con_Cor$Inc_session <- as.numeric(Con_Cor$Inc_session)
Con_Cor_ID$Inc_session <- as.numeric(Con_Cor_ID$Inc_session)

# participant 11 has a very high value, of 11 seconds. 
### plot for the mean values over session, rather than per ID
Stim_D<-ggplot(data = Con_Cor, aes(x = Inc_session, y = mean_Stim_dur)) +
  geom_line(data = Con_Cor_ID, aes(x = Inc_session, y = mean_Stim_dur, 
                                 group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Con_Cor_ID, aes(x = Inc_session, y = mean_Stim_dur),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Con_Cor, aes(x = Inc_session, y = mean_Stim_dur),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  #scale_y_continuous(breaks = seq(0,1500,250),lim = c(0,1500)) +
  coord_cartesian(ylim = c(0,4000)) +
  scale_x_continuous(breaks = seq(0,20,2), lim = c(1,20)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('Stimulus duration') +
  xlab('Sessions') +
  ylab('Duration (ms)') +
  theme_light() +
  theme_classic()

Stim_D

# Saving plots with fixed dimensions, quality etc.
ggsave("Con_Stim_dur.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)




############################### INDIVIDUAL REGRESSION LINES. COLOR PLOTS
###### go rt

Con_S_M <- summarySE(data = Con_train, measurevar = "mean_Corr_goRT_2SD", groupvars = c("Participant","Inc_session"))
Con_S_M$Inc_session <- as.numeric(Con_S_M$Inc_session)

#### line plot to show individual linear lines for each participant over session. EXPERIMENTAL
CON_Reg<- ggplot(data = Con_S_M, aes(x = Inc_session, y = mean_Corr_goRT_2SD, color = Participant, group = Participant)) +
  #scale_x_continuous(breaks = seq(0,20,2), lim = c(1,20)) +
  stat_smooth(data = Con_S_M, aes(x = Inc_session, y = mean_Corr_goRT_2SD, color = Participant), 
              size = 1, alpha = 0.05,  linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  #geom_point() +
  #geom_line(y = 0, linetype = "dashed", colour = "black", size = 1) +
  guides(color = FALSE) +
  #coord_cartesian(ylim = c(0,1200)) +
  #scale_x_log10(breaks=c(5, 6, 7, 8, 9, 10, 11, 30)) +
  scale_x_continuous(breaks = seq(0,20,2), lim = c(1,20)) +
  scale_y_continuous(breaks = seq(0,1000,250), lim = c(0,1000)) +
  ggtitle('Correct RT slopes') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

CON_Reg
# Saving plots with fixed dimensions, quality etc.
ggsave("CON_RT_slopes.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


############# Go RT SD - standard deviation

Con_Cor <- summarySE(data = Con_train, measurevar = "std_Corr_goRT_2SD", groupvars = c("Inc_session"))
Con_Cor_ID <- summarySE(data = Con_train, measurevar = "std_Corr_goRT_2SD", groupvars = c("Participant","Inc_session"))

Con_Cor$Inc_session <- as.numeric(Con_Cor$Inc_session)
Con_Cor_ID$Inc_session <- as.numeric(Con_Cor_ID$Inc_session)

### variability
Con_SD<-ggplot(data = Con_Cor, aes(x = Inc_session, y = std_Corr_goRT_2SD)) +
  geom_line(data = Con_Cor_ID, aes(x = Inc_session, y = std_Corr_goRT_2SD, 
                                   group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Con_Cor_ID, aes(x = Inc_session, y = std_Corr_goRT_2SD),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Con_Cor, aes(x = Inc_session, y = std_Corr_goRT_2SD),size = 4, stroke = 1, shape = 1) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  scale_y_continuous(breaks = seq(0,500,100),lim = c(0,500)) +
  #coord_cartesian(ylim = c(0,4000)) +
  scale_x_continuous(breaks = seq(0,20,2), lim = c(1,20)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('Correct RT standard deviation') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

Con_SD

# Saving plots with fixed dimensions, quality etc.
ggsave("Con_stdRT.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)




##### combine graphs

title <- ggdraw() + 
  draw_label(
    "Response Speed Group",
    fontfamily = "Helvetica",
    fontface = "plain",
    size = 18,
    hjust = 0.5
  )


GG3 <- plot_grid(Con_GoRT, Stim_D, CON_Reg, Con_SD, 
                 align = "h", rel_widths = c(5, 5), ncol =2, labels = "auto")

GG3

plot_grid(
  title, GG3,
  ncol= 1,
  rel_heights = c(0.1,1)
)

GG3_2 <- plot_grid(Con_GoRT, Stim_D, 
                 align = "h", rel_widths = c(5, 5), labels = "auto")

GG3_2

plot_grid(
  title, GG3_2,
  ncol= 1,
  rel_heights = c(0.1,1)
)




# # Saving plots with fixed dimensions, quality etc.
ggsave("CON_Train_Combo.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 10, units = "cm",
       dpi = 300)









#### ------------------------------------------------------------------------------------- ###
#############################  M U L T I L E V E L  M O D E L S  ##############################
###############################################################################################

###############################################################################################
### 9 July 2020 ---- TRAINING DATA EXPERIMENTAL (VERSION 1 DATA)
###############################################################################################

# # outliers?
# install.packages('rstatix')
# library(rstatix)
# 
# ggplot(data = Exp_M) +
#   geom_boxplot(aes(x = Inc_session, y = mean_SSRT1, group = Inc_session)) 


### Multi-level model
### Experimental data

#install.packages('boot')
library(boot)
library(lme4)
# Exp_ID_SSRT1 <- summarySE(data = Exp_train, measurevar = "mean_SSRT1", groupvars = c("Participant","Inc_session"))
# EXP_SSD <- summarySE(data = Exp_train, measurevar = "mean_SSD", groupvars = c("Participant","Inc_session"))
# EXP_goRT <- summarySE(data = Exp_train, measurevar = "mean_Corr_goRT", groupvars = c("Participant","Inc_session"))
# 
# Exp_ID_SSRT1$Participant <- as.numeric(Exp_ID$Participant)
# Exp_ID_SSRT1$Inc_session <- as.numeric(Exp_ID$Inc_session)
# Exp_ID_SSRT1$mean_SSRT1 <- as.numeric(Exp_ID$mean_SSRT1)
# 
# EXP_SSD$Participant <- as.numeric(EXP_SSD$Participant)
# EXP_SSD$Inc_session <- as.numeric(EXP_SSD$Inc_session)
# EXP_SSD$mean_SSD <- as.numeric(EXP_SSD$mean_SSD)
# 
# EXP_goRT$Participant <- as.numeric(EXP_goRT$Participant)
# EXP_goRT$Inc_session <- as.numeric(EXP_goRT$Inc_session)
# EXP_goRT$mean_all_go_RT <- as.numeric(EXP_goRT$mean_Corr_goRT)


#### USE THE WHOLE DATASET INSTEAD

Exp_train$Inc_session <- as.numeric(Exp_train$Inc_session)
Exp_train_2PP$Inc_session <- as.numeric(Exp_train_2PP$Inc_session)

####### SSRT ALL AVAILABLE SESSIONS
# null model
a<-lmer(mean_SSRT1 ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_SSRT1 ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_SSRT1 ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
b <- lmer(mean_SSRT1 ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
anova(b)
confint(b, method = 'boot')



####### SSRT RESTRICTED TO FIRST 8 SESSIONS
# null model
a<-lmer(mean_SSRT1 ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train_2PP)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_SSRT1 ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_SSRT1 ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train_2PP)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
#library(lmerTest)
b <- lmer(mean_SSRT1 ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
anova(b)
confint(b, method = 'boot')




####### SSD ALL AVAILABLE SESSIONS
# null model
a<-lmer(mean_SSD ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_SSD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_SSD ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)


b<-lmer(mean_SSD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
anova(b)
confint(b, method = 'boot')



####### SSD RESTRICTED TO FIRST 8
# null model
a<-lmer(mean_SSD ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train_2PP)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_SSD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_SSD ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train_2PP)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)


b<-lmer(mean_SSD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
anova(b)
confint(b, method = 'boot')





####### all go RT ALL AVAILABLE SESSIONS
# null model
a<-lmer(mean_all_goRT ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_all_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_all_goRT ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

# used model b anyways because fitting model c led to a singular fit
b<-lmer(mean_all_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
anova(b)
confint(b, method = 'boot')




####### all go RT RESTRICTED TO FIRST 8
# null model
a<-lmer(mean_all_goRT ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train_2PP)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_all_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_all_goRT ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train_2PP)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

b<-lmer(mean_all_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
anova(b)
confint(b, method = 'boot')




####### CORRECT go RT ALL AVAILABLE SESSIONS
# null model
a<-lmer(mean_Corr_goRT ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_Corr_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_Corr_goRT ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

# used model b anyways because fitting model c led to a singular fit
c<-lmer(mean_Corr_goRT ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train)
summary(c)
anova(c)
confint(c, method = 'boot')

# used model b anyways because fitting model c led to a singular fit
b<-lmer(mean_Corr_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
summary(b)
anova(b)
confint(b, method = 'boot')




####### CORRECT go RT RESTRICTED TO FIRST 8
# null model
a<-lmer(mean_Corr_goRT ~ 1 + (1 | Participant), REML = FALSE,  data=Exp_train_2PP)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_Corr_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_Corr_goRT ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train_2PP)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

# used model b anyways because fitting model c led to a singular fit
c<-lmer(mean_Corr_goRT ~ Inc_session + (1 + Inc_session | Participant), data=Exp_train_2PP)
summary(c)
anova(c)
confint(c, method = 'boot')

b<-lmer(mean_Corr_goRT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train_2PP)
summary(b)
anova(b)
confint(b, method = 'boot')




###############################################################################################
### 9 July 2020 ---- TRAINING DATA ACTION SELECT 
###############################################################################################


Act_train$Inc_session <- as.numeric(Act_train$Inc_session)

####### Correct reaction action monitoring trials ALL AVAILABLE SESSIONS
# null model
a<-lmer(mean_CorrActSel_RT ~ 1 + (1 | Participant), REML = FALSE,  data=Act_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_CorrActSel_RT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Act_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_CorrActSel_RT ~ Inc_session + (1 + Inc_session | Participant), data=Act_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
b <- lmer(mean_CorrActSel_RT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Act_train)
summary(b)
anova(b)
confint(b, method = 'boot')

###########################################################################
####### Correct reaction action monitoring trials ALL AVAILABLE SESSIONS
#Act_train_SSD <-completeFun(Act_train, "mean_SSD")

# null model
a<-lmer(mean_SSD ~ 1 + (1 | Participant), REML = FALSE,  data=Act_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_SSD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Act_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_SSD ~ Inc_session + (1 + Inc_session | Participant), data=Act_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
b<-lmer(mean_SSD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Act_train)
summary(b)
anova(b)
confint(b, method = 'boot')


###########################################################################
####### Correct reaction action monitoring trials ALL AVAILABLE SESSIONS
#Act_train_SSD <-completeFun(Act_train, "mean_SSD")

# null model
a<-lmer(mean_Corr_go_RT ~ 1 + (1 | Participant), REML = FALSE,  data=Act_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_Corr_go_RT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Act_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_Corr_go_RT ~ Inc_session + (1 + Inc_session | Participant), data=Act_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
c<-lmer(mean_Corr_go_RT ~ Inc_session + (1 | Participant),REML = FALSE,  data=Act_train)
summary(c)
anova(c)
confint(c, method = 'boot')


###############################################################################################
### 20 July 2020 ---- TRAINING DATA CONTROL
###############################################################################################


Con_train$Inc_session <- as.numeric(Con_train$Inc_session)

####### Correct reaction time go trials (Standardised)
# null model
a<-lmer(mean_Corr_goRT_2SD ~ 1 + (1 | Participant), REML = FALSE,  data=Con_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_Corr_goRT_2SD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_Corr_goRT_2SD ~ Inc_session + (1 + Inc_session | Participant), data=Con_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
b <- lmer(mean_Corr_goRT_2SD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
anova(b)
confint(b, method = 'boot')


Con_train$Inc_session <- as.numeric(Con_train$Inc_session)

####### P-hit go trials

Con_train$P_hit_100 <- Con_train$P_Hit*100

# null model
a<-lmer(P_Hit ~ 1 + (1 | Participant), REML = FALSE,  data=Con_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(P_Hit ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(P_Hit ~ Inc_session + (1 + Inc_session | Participant), data=Con_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
b <- lmer(P_hit ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
anova(b)
confint(b, method = 'boot')


####### Stim durations go trials

Con_train$P_hit_100 <- Con_train$P_Hit*100

# null model
a<-lmer(mean_Stim_dur ~ 1 + (1 | Participant), REML = FALSE,  data=Con_train)
summary(a)
(aov <- anova(a))

# random intercept, fixed predictor on individual level
b<-lmer(mean_Stim_dur ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
(aov <- anova(b))
confint(b)

# random intercept, random slope
c<-lmer(mean_Stim_dur ~ Inc_session + (1 + Inc_session | Participant), data=Con_train)
summary(c)
(aov <- anova(c))

# compare models with a likelihood ratio test
anova(a,b,c)

#install.packages('lmerTest')
#install.packages('boot')
#library(boot)
library(lmerTest)
b <- lmer(mean_Stim_dur ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
anova(b)
confint(b, method = 'boot')





###### motivation


Extra_M <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/1_CleaningData_CalculatingSSRT_Matlab/Extra_Measures.csv')

# define groups / factors
Extra_M <- within(Extra_M,{
  Participant <- as.factor(Participant)
  Group <- as.factor(Group)
})

Extra_M <-Extra_M[!(Extra_M$TotalSessions==1),]

#### bonus games
Extra_MG <- summarySE(data = Extra_M, measurevar = "PercentageBonusDone", groupvars = c("Group"))

res.aov <- aov(PercentageBonusDone ~ Group, data = Extra_M)
summary(res.aov)
anova(res.aov)
confint(res.aov, method = 'boot')

### total number of sessions
Extra_MG2 <- summarySE(data = Extra_M, measurevar = "TotalSessions", groupvars = c("Group"))
res.aov <- aov(TotalSessions ~ Group, data = Extra_M)
summary(res.aov)
anova(res.aov)
confint(res.aov, method = 'boot')

### included number of sessions
E <- aggregate(Exp_train$Inc_session, by = list(Exp_train$Participant), max)
E$Group <- 1
A <- aggregate(Act_train$Inc_session, by = list(Act_train$Participant), max)
A$Group <- 2
C <- aggregate(Con_train$Inc_session, by = list(Con_train$Participant), max)
C$Group <- 3

#E <- Exp_train[,c("Participant", "Group", "Inc_session", "Tot_session")]
#A <- Act_train[,c("Participant", "Group", "Inc_session", "Tot_session")]
#C <- Con_train[,c("Participant", "Group", "Inc_session", "Tot_session")]

P <- rbind(E,A,C)

P <-P[!(P$x==1),]

# define groups / factors
P <- within(P,{
  Group.1 <- as.factor(Group.1)
  Group <- as.factor(Group)
})

res.aov <- aov(x ~ Group, data = P)
summary(res.aov)
anova(res.aov)
confint(res.aov, method = 'boot')
TukeyHSD(res.aov)
pairwise.t.test(P$x, P$Group,
                p.adjust.method = "BH")

MG <- summarySE(data = P, measurevar = "x", groupvars = c("Group"))

res.aov <- aov(Inc_session ~ Group, data = P)
summary(res.aov)
anova(res.aov)
confint(res.aov, method = 'boot')




##### Motivation data
Motiv <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/Motivation_Measures.csv')

Motiv <-Motiv[!(Motiv$ID==27),]
Motiv <-Motiv[!(Motiv$ID==16),] # these are not included in the final files, i don't know why. maybe excluded entirely. 

# define groups / factors
Motiv <- within(Motiv,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  School_no <- as.factor(School_no)
  Gender <- as.factor(Gender)
})



keycol <- "Motivation"
valuecol <- "Percentage"
gathercols <- c("Motiv_1", "Motiv_2", "Motiv_3", "Motiv_4")

Motiv_L <- gather_(Motiv, keycol, valuecol, gathercols)

M1 <-Motiv_L[(Motiv_L$Motivation=="Motiv_1"),]
M1$Time <- 1
M2 <-Motiv_L[(Motiv_L$Motivation=="Motiv_2"),]
M2$Time <- 2
M3 <-Motiv_L[(Motiv_L$Motivation=="Motiv_3"),]
M3$Time <- 3
M4 <-Motiv_L[(Motiv_L$Motivation=="Motiv_4"),]
M4$Time <- 4

Mall <- rbind(M1,M2,M3,M4)

Mall <-Mall[!(Mall$Percentage==999),]

Mall <- within(Mall,{
  Group <- as.factor(Group)
  Time <- as.numeric(Time)
})

library(dplyr)

Mall <- na.omit(Mall)

mov_M <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Time","Group"))
mov_M2 <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Time","School_no"))
mov_G <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Group"))
mov_ID <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Time","ID","Group"))

G1_mov <-Mall[(Mall$Group==1),]
mov_ID1 <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Time","ID"))
G2_mov <-Mall[(Mall$Group==2),]
mov_ID2 <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Time","ID"))
G3_mov <-Mall[(Mall$Group==3),]
mov_ID3 <- summarySE(data = Mall, measurevar = "Percentage", groupvars = c("Time","ID"))

mov_M$Time <- as.numeric(mov_M$Time)

cbp1 <- c("#56B4E9", "#E69F00","#999999")

## plot for the mean values over session, rather than per ID
ggplot(data = mov_M, aes(x = Time, y = Percentage, group = Group, colour = Group)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_line(data = mov_M, aes(x = Time, y = Percentage, group = Group), lwd = 1) +
  geom_point() + 
  geom_errorbar(data = mov_M, aes(group = Group, ymin=Percentage-ci, ymax=Percentage+ci), width=.2,
                position=position_dodge(0.25)) +

  #geom_jitter(inherit.aes = FALSE,data = mov_ID1, aes(x = Time, y = Percentage),colour = cbp1[1], shape = 3, width = 0) +
  #geom_jitter(inherit.aes = FALSE,data = mov_ID2, aes(x = Time, y = Percentage),colour = cbp1[2], shape = 3, width = 0.1) +
  #geom_jitter(inherit.aes = FALSE,data = mov_ID3, aes(x = Time, y = Percentage),colour = cbp1[3], shape = 3, width = 0.2) +
  

  scale_y_continuous(breaks = seq(0,100,20), lim = c(0,115)) +

  ggtitle('Motivation trends per group over weeks') +
  xlab('Weeks') +
  ylab('Motivation score') +
  theme_light() +
  theme_classic()



# Saving plots with fixed dimensions, quality etc.
ggsave("Mov_Groups.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 16, units = "cm",
       dpi = 300)




## plot for the mean values over session, rather than per ID
ggplot(data = mov_M2, aes(x = Time, y = Percentage, group = School_no, colour = School_no)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_line(data = mov_M2, aes(x = Time, y = Percentage), lwd = 1) +
  geom_point() + 
  geom_errorbar(data = mov_M2, aes(group = School_no, ymin=Percentage-sd, ymax=Percentage+sd), width=.2,
                position=position_dodge(0.25)) +
  
  #geom_jitter(inherit.aes = FALSE,data = mov_ID1, aes(x = Time, y = Percentage),colour = cbp1[1], shape = 3, width = 0) +
  #geom_jitter(inherit.aes = FALSE,data = mov_ID2, aes(x = Time, y = Percentage),colour = cbp1[2], shape = 3, width = 0.1) +
  #geom_jitter(inherit.aes = FALSE,data = mov_ID3, aes(x = Time, y = Percentage),colour = cbp1[3], shape = 3, width = 0.2) +
  
  
  scale_y_continuous(breaks = seq(0,100,20), lim = c(0,115)) +
  
  ggtitle('Moivation trends per group over weeks with spread') +
  xlab('Weeks') +
  ylab('Motivation score') +
  theme_light() +
  theme_classic()



# Saving plots with fixed dimensions, quality etc.
ggsave("Mov_Groups.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 16, units = "cm",
       dpi = 300)





Mall <- within(Mall,{
  Group <- as.factor(Group)
  Time <- as.numeric(Time)
  School_no<- as.factor(School_no)
})

write.csv(Mall,'/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/M_all.csv', row.names = FALSE)



library(lme4)
fit <- lm(Percentage ~ Time + Group, data=Mall)
summary(fit)
library(lmerTest)
anova(fit)
confint(fit, method = 'boot')



library(lmerTest)
fit <- lmer(Percentage ~ Time + School_no, data=Mall)
summary(fit)
anova(fit)
confint(fit, method = 'boot')
















#### ------------------------------------------------------------------------------------- ###
######################################  PRE POST GRAPHS   #####################################
###############################################################################################

theme_classic()2 <-   theme(
  #legend.position = "none",
  plot.title = element_text(family="Georgia",color="black", size=16 ,hjust = 0.5,margin=margin(0,0,10,0)),
  text = element_text(family="Georgia", size=16),
  legend.title = element_text(size = 12),
  legend.text = element_text(size = 12),
  axis.title.y = element_text(color="black", size=16),
  axis.title.x = element_blank(),
  #axis.title.x = element_text(color="black", size=14, margin=margin(8,0,0,0)),
  axis.text.x = element_text(size = 14, margin=margin(5,0,0,0)),
  axis.text.y = element_text(size = 12, margin=margin(0,5,0,10)),
  legend.position = c(0.15, 0.83),
  legend.justification = c("center"),
  legend.box.just = "left",
  legend.margin = margin(6, 30, 6, 6),
  legend.box.background = element_rect(color="black", size=1),
  plot.margin = margin(6, 15, 6, 15)
)


#install.packages("RColorBrewer")
library(RColorBrewer)

mypal2 = c("#bce4c8","#55bdd4")
mypal2_prev = c("#cab2d6", "#6a3d9a")
mypalold = c("#56B4E9", "#E69F00")
mypalette = c("#E69F00","#6baed6","#08306b")

###############################################################################################
#PrePost <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/Analysis File AX_CPTSSRT_MIXEDMODEL.csv')
PrePost <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/final_elisa.csv')

names(PrePost)[1] <- "ID"
names(PrePost)[3] <- "ID_2"

# define groups / factors
PrePost <- within(PrePost,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  session <- as.factor(session)
})

PrePost <-PrePost[!(PrePost$session==2),]


names(PrePost)[23] <- "1"
names(PrePost)[24] <- "2"

keycol <- "Time"
valuecol <- "SSRT"
gathercols <- c("1", "2")

PreP_SSRT <- gather_(PrePost, keycol, valuecol, gathercols)


PreP_SSRT <-PreP_SSRT[!(PreP_SSRT$SSRT<0),]
PreP_SSRT_NA <-completeFun(PreP_SSRT, "SSRT") 


# define groups / factors
PreP_SSRT_NA <- within(PreP_SSRT_NA,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  Time <- as.factor(Time)
})

PreP_SSRT_NA_M <- summarySE(data = PreP_SSRT_NA, measurevar ="SSRT", groupvars = c("Time","Group"))


PP_SSRT<- ggplot(data = PreP_SSRT_NA, aes(x = factor(Group), y = SSRT, fill = Time)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_bar(data = PreP_SSRT_NA_M, aes(x = Group, y = SSRT), position = "dodge", 
           stat = "identity",width = 0.6, alpha = 1, size = 0.8, colour = "black") +
  geom_point(position = position_jitterdodge(jitter.width = 0.15), shape = 5,
             size = 2) +
  geom_errorbar(data = PreP_SSRT_NA_M, aes(x = Group, ymin=SSRT-ci, ymax=SSRT+ci), position=position_dodge(.6),
                width = 0.4, size = 1, color = "black") +
  scale_y_continuous(breaks = seq(0,0.6,0.1), lim = c(0,0.6)) +
  scale_fill_manual(values = mypal2, labels = c("Pre", "Post")) +
  scale_x_discrete(labels = c("Inhibition", "Context", "Speed")) +
  #guides(fill = FALSE) +
  guides(title = "Time", labels = c("Pre","Post")) +
  #scale_fill_brewer() +
  #geom_point(data = PreP_SSRT_NA, aes(x = factor(Group), y = SSRT)) +
  #geom_boxplot() + 
  labs(y = "SSRT (sec)") +
  theme_light() +
  theme_classic()2

PP_SSRT

# Saving plots with fixed dimensions, quality etc.
ggsave("PrePostSSRT.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


###################### SSD


names(PrePost)[25] <- "3"
names(PrePost)[26] <- "4"

keycol <- "Time"
valuecol <- "SSD"
gathercols <- c("3", "4")

PreP_SSD <- gather_(PrePost, keycol, valuecol, gathercols)

PreP_SSD_NA <-completeFun(PreP_SSD, "SSD") 


# define groups / factors
PreP_SSD_NA <- within(PreP_SSD_NA,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  Time <- as.factor(Time)
})


PreP_SSD_NA_M <- summarySE(data = PreP_SSD_NA, measurevar ="SSD", groupvars = c("Time","Group"))

PreP_SSD_NA_ID <- summarySE(data = PreP_SSD_NA, measurevar ="SSD", groupvars = c("Time","ID"))


PP_SSD<-ggplot(data = PreP_SSD_NA, aes(x = factor(Group), y = SSD, fill = Time)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_bar(data = PreP_SSD_NA_M, aes(x = Group, y = SSD), position = "dodge", 
           stat = "identity",width = 0.6, alpha = 1, size = 0.8, colour = "black") +
  geom_point(position = position_jitterdodge(jitter.width = 0.15), shape = 5,
             size = 2) +
  geom_errorbar(data = PreP_SSD_NA_M, aes(x = Group, ymin=SSD-ci, ymax=SSD+ci), position=position_dodge(.6),
                width = 0.4, size = 1, color = "black") +
  scale_y_continuous(breaks = seq(0,0.6,0.1), lim = c(0,0.6)) +
  scale_fill_manual(values = mypal2, labels = c("Pre", "Post")) +
  scale_x_discrete(labels = c("Inhibition", "Context", "Speed")) +
  #scale_x_discrete(labels = c("Response Inhibition", "Context Monitoring", "Response Speed")) +
  guides(fill = FALSE) +
  #scale_fill_brewer() +
  labs(y = "SSD (sec)") +
  theme_light() +
  theme_classic()2

PP_SSD


# Saving plots with fixed dimensions, quality etc.
ggsave("PrePostSSD.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)




###################### Correct inhibition


names(PrePost)[27] <- "5"
names(PrePost)[28] <- "6"

keycol <- "Time"
valuecol <- "Corr"
gathercols <- c("5", "6")

PreP_Corr <- gather_(PrePost, keycol, valuecol, gathercols)

PreP_Corr_NA <-completeFun(PreP_Corr, "Corr") 


# define groups / factors
PreP_Corr_NA <- within(PreP_Corr_NA,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  Time <- as.factor(Time)
})


Prep_Corr_NA_M <- summarySE(data = PreP_Corr_NA, measurevar ="Corr", groupvars = c("Time","Group"))

#PreP_SSD_NA_ID <- summarySE(data = PreP_Corr_NA, measurevar ="Corr", groupvars = c("Time","ID"))


PP_CORR<-ggplot(data = PreP_Corr_NA, aes(x = factor(Group), y = Corr, fill = Time)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_bar(data = Prep_Corr_NA_M, aes(x = Group, y = Corr), position = "dodge", 
           stat = "identity",width = 0.6, alpha = 1, size = 0.8, colour = "black") +
  geom_point(position = position_jitterdodge(jitter.width = 0.15), shape = 5,
             size = 2) +
  geom_errorbar(data = Prep_Corr_NA_M, aes(x = Group, ymin=Corr-ci, ymax=Corr+ci), position=position_dodge(.6),
                width = 0.4, size = 1, color = "black") +
  scale_y_continuous(breaks = seq(0,1,0.2), lim = c(0,1)) +
  scale_fill_manual(values = mypal2, labels = c("Pre", "Post")) +
  scale_x_discrete(labels = c("Inhibition", "Context", "Speed")) +
  #scale_x_discrete(labels = c("Response Inhibition", "Context Monitoring", "Response Speed")) +
  guides(fill = FALSE) +
  #guides(title = "Time", labels = c("Pre","Post")) +
  #scale_fill_brewer() +
  labs(y = "Percentage (%)") +
  theme_light() +
  theme_classic()2

PP_CORR

# Saving plots with fixed dimensions, quality etc.
ggsave("PrePostCorr.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


################# Go reaction time mean goRT


names(PrePost)[29] <- "7"
names(PrePost)[30] <- "8"

keycol <- "Time"
valuecol <- "GoRT"
gathercols <- c("7", "8")

PreP_GoRT <- gather_(PrePost, keycol, valuecol, gathercols)

PreP_GoRT_NA <-completeFun(PreP_GoRT, "GoRT") 


# define groups / factors
PreP_GoRT_NA <- within(PreP_GoRT_NA,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  Time <- as.factor(Time)
})

PreP_GoRT_NA_M <- summarySE(data = PreP_GoRT_NA, measurevar ="GoRT", groupvars = c("Time","Group"))


PP_GoRT<- ggplot(data = PreP_GoRT_NA, aes(x = factor(Group), y = GoRT, fill = Time)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_bar(data = PreP_GoRT_NA_M, aes(x = Group, y = GoRT), position = "dodge", 
           stat = "identity",width = 0.6, alpha = 1, size = 0.8, colour = "black") +
  geom_point(position = position_jitterdodge(jitter.width = 0.15), shape = 5,
             size = 2) +
  geom_errorbar(data = PreP_GoRT_NA_M, aes(x = Group, ymin=GoRT-ci, ymax=GoRT+ci), position=position_dodge(.6),
                width = 0.4, size = 1, color = "black") +
  scale_y_continuous(breaks = seq(0,1,0.2), lim = c(0,1)) +
  scale_fill_manual(values = mypal2, labels = c("Pre", "Post")) +
  scale_x_discrete(labels = c("Inhibition", "Context", "Speed")) +
  guides(fill = FALSE) +
  #guides(title = "Time", labels = c("Pre","Post")) +
  #scale_fill_brewer() +
  #geom_point(data = PreP_SSRT_NA, aes(x = factor(Group), y = SSRT)) +
  #geom_boxplot() + 
  labs(y = "Go Reaction Time (s)") +
  theme_light() +
  theme_classic()2

PP_GoRT

# Saving plots with fixed dimensions, quality etc.
ggsave("PrePostGoRT.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)





################# proactive response score

PrePost <- read.csv('/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/Analysis File AX_CPTSSRT_MIXEDMODEL.csv')

names(PrePost)[1] <- "ID"

# define groups / factors
PrePost <- within(PrePost,{
  ID <- as.factor(ID)
  Group <- as.factor(Group)
  TimePoint <- as.factor(TimePoint)
})

PrePost2 <-completeFun(PrePost, "AYBX_Error") 


PrePost_M <- summarySE(data = PrePost2, measurevar ="AYBX_Error", groupvars = c("TimePoint","Group"))

#PreP_SSD_NA_ID <- summarySE(data = PreP_Corr_NA, measurevar ="Corr", groupvars = c("Time","ID"))


PP_ERR<-ggplot(data = PrePost2, aes(x = factor(Group), y = AYBX_Error, fill = TimePoint)) +
  scale_color_manual(values = cbp1, labels = c("Inhibition", "Context", "Speed"))+
  geom_bar(data = PrePost_M, aes(x = Group, y = AYBX_Error), position = "dodge", 
           stat = "identity",width = 0.6, alpha = 1, size = 0.8, colour = "black") +
  geom_point(position = position_jitterdodge(jitter.width = 0.15), shape = 5,
             size = 2) +
  geom_errorbar(data = PrePost_M, aes(x = Group, ymin=AYBX_Error-ci, ymax=AYBX_Error+ci), position=position_dodge(.6),
                width = 0.4, size = 1, color = "black") +
  scale_y_continuous(breaks = seq(-0.5,0.5,0.25), lim = c(-0.65,0.70)) +
  scale_fill_manual(values = mypal2, labels = c("Pre", "Post")) +
  scale_x_discrete(labels = c("Inhibition", "Context", "Speed")) +
  #scale_x_discrete(labels = c("Response Inhibition", "Context Monitoring", "Response Speed")) +
  guides(fill = FALSE) +
  #guides(title = "Time", labels = c("Pre","Post")) +
  #scale_fill_brewer() +
  #labs(y = "Proactive Score (%)") +
  labs(y = "Proactive Control Score (%)") +
  theme_light() +
  theme_classic()2

PP_ERR

# Saving plots with fixed dimensions, quality etc.
ggsave("PrePostErr2.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)






##### combine graphs

title <- ggdraw() + 
  draw_label(
    "Indices of cognitive control pre- and post-training",
    fontfamily = "Helvetica",
    fontface = "plain",
    size = 18,
    hjust = 0.5
  )


# GG4_1 <- plot_grid(PP_SSRT, PP_SSD, 
#                  align = "h", rel_widths = c(4, 5), ncol =2, labels = "auto")
# 
# GG4_1
# 
# GG4_2 <- plot_grid(PP_CORR, PP_ERR, 
#                    align = "h", rel_widths = c(4, 4), ncol =2, labels = "auto")
# 
# GG4_2
# 
# GG4_3 <- plot_grid(PP_SSRT, PP_SSD,PP_CORR, PP_GoRT, 
#                    align = "h", rel_widths = c(4, 4), rel_heights = c(0.7,0.7), ncol =2, labels = "auto")
# 
# GG4_3
# 
# g5 <- plot_grid(GG4_3,
#                 PP_ERR, NULL, 
#                 rel_widths = c(4,4),labels = "e")
# g5



GG5 <- plot_grid(PP_SSRT, PP_SSD, PP_CORR, PP_GoRT, PP_ERR,
                   align = "h", rel_widths = c(1, 1), rel_heights = c(0.5,0.5), 
                    theme(plot.margin = margin(0, 0, 10, 0)), ncol =2,
                 labels = c("a","b","c","d","e"))

GG5

GG6 <- plot_grid(title,GG5,nrow = 2, rel_heights = c(0.05,0.9))

GG6


# # Saving plots with fixed dimensions, quality etc.
ggsave("PrePost_Combo_5Graphs.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 28, units = "cm",
       dpi = 300)




### put the graph in the middle?

GG4 <- plot_grid(PP_SSRT, PP_SSD, PP_CORR, PP_GoRT,
                 align = "h", rel_widths = c(1, 1), rel_heights = c(0.5,0.5), 
                 theme(plot.margin = margin(0, 0, 10, 0)), ncol =2
                 )
GG4

GG5 <- plot_grid(GG4,PP_ERR, nrow = 2,rel_heights = c(0.7,0.3), labels = c("a","b","c","d","e"))
GG5

GG6 <- plot_grid(title,GG5,nrow = 2, rel_heights = c(0.05,0.9))

GG6


# # Saving plots with fixed dimensions, quality etc.
ggsave("PrePost_Combo_5Graphs2.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 24, height = 28, units = "cm",
       dpi = 300)





######################################################################################
### ------------------ INDIVIDUAL REGRESSION SLOPE DATA

# ############################### SSRT 1 INDIVIDUAL REGRESSION LINES. COLOR PLOTS
Exp_S_M <- summarySE(data = Exp_train, measurevar = "mean_SSRT1", groupvars = c("Participant","Inc_session"))
Exp_S_M$Inc_session <- as.numeric(Exp_S_M$Inc_session)
x<-unique(Exp_S_M$Participant)

#coefs<- cbind(as.character(1:length(x)),as.character(1:length(x)),as.character(1:length(x)))

t_Id <- vector()
t_coef <- vector()

for (i in x) {
  # Create temporary data frame:
  snarc_tmp <-
    Exp_S_M[Exp_S_M$Participant==i,]
  # Perform regression:
  reg_result <- lm(snarc_tmp$mean_SSRT1 ~
                     snarc_tmp$Inc_session)
  # Get coefficient:
  tmp_coef <- coef(reg_result)
  # Store coefficient:
  t_Id[i] <- i
  t_coef[i] <- tmp_coef[2]
  #coefs[i,1] <- x[i]
  #coefs[i,2] <- tmp_coef[1]
  #coefs[i,3] <- tmp_coef[2]
}

out <- cbind(t_Id, t_coef)

# for action select group
Act_S_M <- summarySE(data = Act_train, measurevar = "mean_CorrActSel_RT", groupvars = c("Participant","Inc_session"))
Act_S_M$Inc_session <- as.numeric(Act_S_M$Inc_session)
x<-unique(Act_S_M$Participant)

t_Id <- vector()
t_coef <- vector()

for (i in x) {
  # Create temporary data frame:
  snarc_tmp <-
    Act_S_M[Act_S_M$Participant==i,]
  # Perform regression:
  reg_result <- lm(snarc_tmp$mean_CorrActSel_RT ~
                     snarc_tmp$Inc_session)
  # Get coefficient:
  tmp_coef <- coef(reg_result)
  # Store coefficient:
  t_Id[i] <- i
  t_coef[i] <- tmp_coef[2]
  #coefs[i,1] <- x[i]
  #coefs[i,2] <- tmp_coef[1]
  #coefs[i,3] <- tmp_coef[2]
}

out <- cbind(t_Id, t_coef)

# for control group
Con_S_M <- summarySE(data = Con_train, measurevar = "mean_Corr_goRT", groupvars = c("Participant","Inc_session"))
Con_S_M$Inc_session <- as.numeric(Con_S_M$Inc_session)
x<-unique(Con_S_M$Participant)

t_Id <- vector()
t_coef <- vector()

for (i in x) {
  # Create temporary data frame:
  snarc_tmp <-
    Con_S_M[Con_S_M$Participant==i,]
  # Perform regression:
  reg_result <- lm(snarc_tmp$mean_Corr_goRT ~
                     snarc_tmp$Inc_session)
  # Get coefficient:
  tmp_coef <- coef(reg_result)
  # Store coefficient:
  t_Id[i] <- i
  t_coef[i] <- tmp_coef[2]
  #coefs[i,1] <- x[i]
  #coefs[i,2] <- tmp_coef[1]
  #coefs[i,3] <- tmp_coef[2]
}

out <- cbind(t_Id, t_coef)

# for (i in x) {
#   # Create temporary data frame:
#   snarc_tmp <-
#     Exp_S_M[Exp_S_M$Participant==i,]
#   # Perform regression:
#   reg_result <- lmer(mean_SSRT1 ~ Inc_session ,REML = FALSE,  data=Exp_S_M)
#   # Get coefficient:
#   tmp_coef <- coef(reg_result)
#   # Store coefficient:
#   coefs[i,1] <- snarc_tmp$Participant[1]
#   coefs[i,2] <- tmp_coef[1]
#   coefs[i,3] <- tmp_coef[2]
# }
# 
# 
# for (sub in x) {
# # Create temporary data frame:
# snarc_tmp <-
#   Exp_S_M[Exp_S_M$Participant==i,]
# # Perform regression:
# reg_result <- lm(snarc_tmp$mean_SSRT1 ~
#                    snarc_tmp$Inc_session)
# # Get coefficient:
# tmp_coef <- coef(reg_result)
# # Store coefficient:
# snarc_coefs[i] <- tmp_coef[2]
# }
# 
# 
# for (sub in x) {
#   # Create temporary data frame:
#   snarc_tmp <-
#     Exp_S_M[Exp_S_M$Participant==1,]
#   # Perform regression:
#   reg_result <- lm(snarc_tmp$mean_SSRT1 ~
#                      snarc_tmp$Inc_session)
#   # Get coefficient:
#   tmp_coef <- coef(reg_result)
#   # Store coefficient:
#   snarc_coefs[i] <- tmp_coef[2]
# }





############# CovVar RT

# create means per session over the games
Con_Cor <- summarySE(data = Con_train, measurevar = "CovVar_Corr_goRT", groupvars = c("Inc_session"))
Con_Cor_ID <- summarySE(data = Con_train, measurevar = "CovVar_Corr_goRT", groupvars = c("Participant","Inc_session"))

Con_Cor$Inc_session <- as.numeric(Con_Cor$Inc_session)
Con_Cor_ID$Inc_session <- as.numeric(Con_Cor_ID$Inc_session)

### plot for the mean values over session, rather than per ID
Con_RT_G <- ggplot(data = Con_Cor, aes(x = Inc_session, y = CovVar_Corr_goRT)) +
  geom_line(data = Con_Cor_ID, aes(x = Inc_session, y = CovVar_Corr_goRT, 
                                   group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Con_Cor, aes(x = Inc_session, y = CovVar_Corr_goRT),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Con_Cor, aes(x = Inc_session, y = CovVar_Corr_goRT),size = 4, stroke = 1, shape = 21) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  #scale_y_continuous(breaks = seq(0,1,250),lim = c(0,1250)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  #coord_cartesian(ylim = c(0,300)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('RT variability for correct trials over sessions (control group)') +
  #ggtitle('Mean reaction time for go trials per session\nfor the response inhibition group') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

Con_RT_G

# Saving plots with fixed dimensions, quality etc.
ggsave("Con_RT_Cov_ID.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)


# create means per session over the games
Exp_Cor <- summarySE(data = Exp_train, measurevar = "CovVar_Corr_goRT", groupvars = c("Inc_session"))
Exp_Cor_ID <- summarySE(data = Exp_train, measurevar = "CovVar_Corr_goRT", groupvars = c("Participant","Inc_session"))

Exp_Cor$Inc_session <- as.numeric(Exp_Cor$Inc_session)
Exp_Cor_ID$Inc_session <- as.numeric(Exp_Cor_ID$Inc_session)

### plot for the mean values over session, rather than per ID
Con_RT_G <- ggplot(data = Exp_Cor, aes(x = Inc_session, y = CovVar_Corr_goRT)) +
  geom_line(data = Exp_Cor_ID, aes(x = Inc_session, y = CovVar_Corr_goRT, 
                                   group = Participant, linetype = Participant),colour = "black",lwd=0.5, alpha = 0.5) +
  stat_smooth(data = Exp_Cor, aes(x = Inc_session, y = CovVar_Corr_goRT),size = 1, alpha = 0.4,
              color = "black", linetype = "solid", method = "lm", formula = y ~ x, se = T) +
  geom_point(data = Exp_Cor, aes(x = Inc_session, y = CovVar_Corr_goRT),size = 4, stroke = 1, shape = 21) +
  #geom_line(stat="identity") +
  guides(color = FALSE, linetype = FALSE) +
  #scale_y_continuous(breaks = seq(0,1250,250),lim = c(0,1250)) +
  scale_x_continuous(breaks = seq(1,11,1), lim = c(1,11)) +
  #coord_cartesian(ylim = c(0,300)) +
  #scale_x_continuous(breaks = seq(1,9,1), lim = c(1,9)) +
  ggtitle('RT variability for correct trials over sessions (training group)') +
  #ggtitle('Mean reaction time for go trials per session\nfor the response inhibition group') +
  xlab('Sessions') +
  ylab('Reaction time (ms)') +
  theme_light() +
  theme_classic()

Con_RT_G

# Saving plots with fixed dimensions, quality etc.
ggsave("Exp_RT_Cov_ID.png", plot = last_plot(), path = '/Users/k.ganesan/Dropbox/Final_Training_Data_Analysis_KG/2_Analysing_training_data_R/',
       scale = 1, width = 20, height = 16, units = "cm",
       dpi = 300)
