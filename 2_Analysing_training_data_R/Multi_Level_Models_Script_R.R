#### Final October Pilot analysis script ####

#### ------------------------------------------------------------------------------------- ###
#############################  M U L T I L E V E L  M O D E L S  ##############################
###############################################################################################

###############################################################################################
### 9 July 2020 ---- TRAINING DATA EXPERIMENTAL (VERSION 1 DATA)
###############################################################################################

# # outliers?
# install.packages('rstatix')
# library(rstatix)


#install.packages('boot')
library(boot)
library(lme4)


#### USE THE WHOLE DATASET 

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


library(lmerTest)
b <- lmer(mean_SSRT1 ~ Inc_session + (1 | Participant),REML = FALSE,  data=Exp_train)
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



b <- lmer(mean_Corr_goRT_2SD ~ Inc_session + (1 | Participant),REML = FALSE,  data=Con_train)
summary(b)
anova(b)
confint(b, method = 'boot')


Con_train$Inc_session <- as.numeric(Con_train$Inc_session)


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


Extra_M <- read.csv('/Users/claire.smid/Dropbox/October_Pilot/Final_Training_Data_Analysis/1_CleaningData_CalculatingSSRT_Matlab/Extra_Measures.csv')

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
Motiv <- read.csv('/Users/claire.smid/Dropbox/October_Pilot/Final_Training_Data_Analysis/2_Analysing_training_data_R/Motivation_Measures.csv')

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


Mall <- within(Mall,{
  Group <- as.factor(Group)
  Time <- as.numeric(Time)
  School_no<- as.factor(School_no)
})

write.csv(Mall,'/Users/claire.smid/Dropbox/October_Pilot/Final_Training_Data_Analysis/2_Analysing_training_data_R/M_all.csv', row.names = FALSE)



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










