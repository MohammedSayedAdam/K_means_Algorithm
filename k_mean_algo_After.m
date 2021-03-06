%after importing data sample file and make first column as a text not catg
%we sum all its three vars (cases,recovers,deaths)so that we got x,y,z for
%all cities so that we can apply ecludian distance
close all
clear
clc
%----------------------------------------------------------%
DataSett = readtable('DataSett.xlsx');
DataSett.City = string(DataSett.City);
word_dataset = readtable('word_dataset.xlsx');
word_dataset.City = string(word_dataset.City);
%-----------------------------------------------------------%
choice = menu('Choose which data set you work on','DataSett','word_dataset');
prompt = {'Enter the number of clusters you want?'};
dlg_title = 'input';
num_lines = 1;
def = {''};
answer = inputdlg(prompt,dlg_title,num_lines,def,"off");
K = cellfun(@str2num,answer);
cities=[];
cases = [];sum1 = 0;
recovers = [];sum2 = 0;
deaths = [];sum3 = 0;
if choice == 1
        for i=1: height(DataSett(:,"City"))-1
        sum1 = sum1 + DataSett.Cases(i);
        sum2 = sum2 + DataSett.Recovers(i);
        sum3 = sum3 + DataSett.Deaths(i);
        if(i==height(DataSett(:,"City"))-1)
            sum1 = sum1 + DataSett.Cases(i+1);
            sum2 = sum2 + DataSett.Recovers(i+1);
            sum3 = sum3 + DataSett.Deaths(i+1);
            cases = [cases,sum1];
            recovers = [recovers,sum2];
            deaths = [deaths,sum3];sum1=0;sum2=0;sum3=0;
        end
        if(DataSett.City(i)==DataSett.City(i+1)||DataSett.City(i)==DataSett.City(i+1)+" ")
            if(i==1)
                cities = [cities,DataSett.City(i)]; 
            end
            continue;
        else
            cities = [cities,DataSett.City(i+1)];
            cases = [cases,sum1];
            recovers = [recovers,sum2];
            deaths = [deaths,sum3];sum1=0;sum2=0;sum3=0;
        end  
    end
else
        for i=1: height(word_dataset(:,"City"))
            sum1 =  word_dataset.Cases(i);
            sum2 =  word_dataset.Recovers(i);
            sum3 =  word_dataset.Deaths(i);
            cities = [cities,word_dataset.City(i)];
            cases = [cases,sum1];
            recovers = [recovers,sum2];
            deaths = [deaths,sum3];
        end  
end

%plot(recovers(:),deaths(:),'.') ; 
%K = input("Enter the number of clusters you want?");
%time elapsed here
tic
%generate random numbers with the same k numbers
randompos = randperm(length(cities),K);%choose random numbers without repeating numbers
means = [];
for i=1:K
  means = [means;[cases(randompos(i)) recovers(randompos(i)) deaths(randompos(i))]];
end
%from here start with k-mean algorithm
distances = [];
clusters = [];
old_clusters = [];
c = 1;
calc = [];
kpos_all = [];
iterations_num = 0;
while(true)
   for i=1:length(cities)
        m = 99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999;
        for j=1:K
            d1 = (cases(i)-means(j,1))^2;
            d2 = (recovers(i)-means(j,2))^2;
            d3 = (deaths(i)-means(j,3))^2;
            calc = [calc sqrt(d1+d2+d3)];
            if(m>calc(c))
                m = calc(c);
                pos = j;
            end 
            c= c + 1;
        end
        clusters = [clusters,pos];
   end
   
   %kpos_all = [kpos_all,[clusters]];
    %new centroids new means
    means = [];
    for i=1:K
        kpos = [];
        avgcases =0;
        avgrecovers =0;
        avgdeath =0 ;
        %to get positions of the last means
        for j=1:length(clusters)
            if(clusters(j)==i)
                kpos = [kpos,j];
            end
        end
        %kpos_all = [kpos_all,[kpos]];
        %determine new means to continue clustering every point
        for j=1:length(kpos)
             avgcases = avgcases + cases(kpos(j)) ;
             avgrecovers = avgrecovers + recovers(kpos(j)) ;
             avgdeath = avgdeath + deaths(kpos(j)) ;
        end
        avgcases = avgcases / length(kpos) ;
        avgrecovers = avgrecovers / length(kpos) ;
        avgdeath = avgdeath / length(kpos) ;
        means = [means;[avgcases avgrecovers avgdeath]];
    end
    if(length(old_clusters)~=0)
        if(old_clusters == clusters)
            break;
         end
    end
   old_clusters = clusters;  
   clusters = [];
   iterations_num = iterations_num + 1;
end
%to show time and num of iterations
toc
iterations_num
% to show what are the closeset citeis in distance
final_cities = [];
for i=1:K
    kpos = [];
    for j=1:length(clusters)
        if(clusters(j)==i)
            kpos = [kpos,j];
        end
    end
    for j=1:length(kpos)
        if j==1
            fprintf("[cluster number] %d Contains %d\n",i,length(kpos));
        end
        fprintf("%s\n",(cities(kpos(j))) );
        final_cities = [final_cities,[i;cities(kpos(j))]];
    end
end