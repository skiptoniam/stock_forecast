d <- read.table('https://raw.githubusercontent.com/ozt-ca/tjo.hatenablog.samples/master/r_samples/public_lib/jp/hb_trend_nonlinear.txt',header = TRUE)

par(mfrow=c(4,1),mar=c(1,6,1,1))
plot(d$y,type='l',lwd=3,col='red')
plot(d$x1,type='l',lwd=1.5)
plot(d$x2,type='l',lwd=1.5)
plot(d$x3,type='l',lwd=1.5)

d.lm<-lm(y~.,d)
matplot(cbind(d$y,predict(d.lm,d[,-4])),type='l',lty=1,lwd=3,col=c(1,2))

# try and build stan model that can model the non-linear trend in this data.
# install.packages('rstan')
library(rstan)
dat<-list(N=100,x1=d$x1,x2=d$x2,x3=d$x3,y=d$y)
fit1<-stan(file='src/hb_ts_mod.stan',data=dat,iter=1000,chains=4)
library(coda)
fit1.coda<-mcmc.list(lapply(1:ncol(fit1),function(x) mcmc(as.array(fit1)[,x,])))
plot(fit1.coda)

fit1.smp<-extract(fit1)
dens_a<-density(fit1.smp$a)
dens_b<-density(fit1.smp$b)
dens_c<-density(fit1.smp$c)
dens_d<-density(fit1.smp$d)
a_est<-dens_a$x[dens_a$y==max(dens_a$y)]
b_est<-dens_b$x[dens_b$y==max(dens_b$y)]
c_est<-dens_c$x[dens_c$y==max(dens_c$y)]
d_est<-dens_d$x[dens_d$y==max(dens_d$y)]
trend_est<-rep(0,100)
for (i in 1:100) {
       tmp<-density(fit1.smp$trend[,i])
       trend_est[i]<-tmp$x[tmp$y==max(tmp$y)]
  }
pred<-a_est*d$x1+b_est*d$x2+c_est*d$x3+d_est+cumsum(trend_est)
par(mfrow=c(1,1))
matplot(cbind(d$y,pred),type='l',lty=1,lwd=c(2,3),col=c(1,2))
legend('topleft',legend=c('Data','Predicted'),col=c(1,2),lty=1,lwd=3,ncol=2,cex=1.5)

## Now try to include the weekly trend.
## Hierachical bayesian model for time series data.

fit2<-stan(file='src/hb_ts_mod2.stan',data=dat,iter=1000,chains=4)
fit2.smp<-extract(fit2)
dens2_a<-density(fit2.smp$a)
dens2_b<-density(fit2.smp$b)
dens2_c<-density(fit2.smp$c)
dens2_d<-density(fit2.smp$d)
a_est2<-dens2_a$x[dens2_a$y==max(dens2_a$y)]
b_est2<-dens2_b$x[dens2_b$y==max(dens2_b$y)]
c_est2<-dens2_c$x[dens2_c$y==max(dens2_c$y)]
d_est2<-dens2_d$x[dens2_d$y==max(dens2_d$y)]
trend_est2<-rep(0,100)
for (i in 1:100) {
     tmp<-density(fit2.smp$trend[,i])
     trend_est2[i]<-tmp$x[tmp$y==max(tmp$y)]
 }
week_est2<-rep(0,100)
for (i in 1:100) {
     tmp<-density(fit2.smp$season[,i])
     week_est2[i]<-tmp$x[tmp$y==max(tmp$y)]
 }
pred2<-a_est2*d$x1+b_est2*d$x2+c_est2*d$x3+d_est2+cumsum(trend_est2)+week_est2
matplot(cbind(d$y,pred2),type='l',lty=1,lwd=c(2,3),col=c(1,2))
legend('topleft',c('Data','Predicted'),col=c(1,2),lty=1,lwd=c(2,3),cex=1.5,ncol=2)

cor(d$y,pred)
cor(d$y,pred2)


matplot(cbind(d$y,pred2,cumsum(trend_est2)+d_est2,week_est2+cumsum(trend_est2)+d_est2),type='l',lty=1,lwd=c(2,3,2,2),col=c('black','red','blue','green'))
legend('topleft',c('Data','Predicted','Trend','Seasonality + Trend'),col=c('black','red','blue','green'),lty=1,lwd=c(2,3,2,2),cex=1.2,ncol=2)
