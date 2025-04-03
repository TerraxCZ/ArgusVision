clearvars;close all;clc;

pix_size = 1.85*10^-3;  %[mm]

MK1_Hg = imread("HgVybojkaNaDebilnimPripravkuNaCogry.bmp");
%Rtutova MK2
MK2_Hg0 = imread("HgLampaZaostreny_0r.bmp");
MK2_HgREST = imread("HgLampaZaostreny_asiVsechny.bmp");
%Sodikova MK2
MK2_Na0 = imread('NaLampaZaostreny_0r.bmp');
MK2_Na1 = imread('NaLampaZaostrena_1radNeco.bmp');
MK2_Na2 = imread('NaLampaZaostreny_1radDubletASI.bmp');


MK2_Hg_combined = zeros(3036,4024,'uint8');
MK2_Hg_combined(:,1:400) = MK2_Hg0(:,1:400);
MK2_Hg_combined(:,1700:3200) = MK2_HgREST(:,1700:3200);

HgBarvy = [365 405 436 546 579];    %[nm]

figure(1)
rotatedHg = imrotate(MK2_Hg_combined,0.8594,'crop');
imshow(rotatedHg)

figure(2)

imshow(rotatedHg)
hold on
xline(229,'--',{'pixel = 229    0. řád','0.4237 mm'},'Color',[1 1 1],'LabelVerticalAlignment', 'bottom')
xline(1898,'--',{'pixel = 1898    365nm','3.5113 mm'},'Color',[0.3804 0 0.3804],'LabelVerticalAlignment', 'bottom')
xline(2080,'--',{'pixel = 2080    405nm','3.848 mm'},'Color',[0.5098 0 0.7843],'LabelVerticalAlignment', 'top')
xline(2224,'--',{'pixel = 2224    436nm','4.1144 mm'},'Color',[0.1137 0 1],'LabelVerticalAlignment', 'bottom')
xline(2736,'--',{'pixel = 2736    546nm','5.0616 mm'},'Color',[0.5882 1 0],'LabelVerticalAlignment', 'top')
xline(2887,'--',{'pixel = 2887    579nm','5.341 mm'},'Color',[0.9882 1 0],'LabelVerticalAlignment', 'bottom')
HgPolohy = [229 1898 2080 2224 2736 2887];  %polohy spicek pri mereni Hg (Absolutni)

figure(3)
imshow(rotatedHg)
hold on
xline(229,'--',{'pixel = 229    0. řád','0.4237 mm'},'Color',[1 1 1],'LabelVerticalAlignment', 'bottom')
xline(1898,'--',{'pixel = 1898    365nm','3.5113 mm'},'Color',[0.3804 0 0.3804],'LabelVerticalAlignment', 'bottom')
xline(2080,'--',{'pixel = 2080    405nm','3.848 mm'},'Color',[0.5098 0 0.7843],'LabelVerticalAlignment', 'top')
xline(2224,'--',{'pixel = 2224    436nm','4.1144 mm'},'Color',[0.1137 0 1],'LabelVerticalAlignment', 'bottom')
xline(2736,'--',{'pixel = 2736    546nm','5.0616 mm'},'Color',[0.5882 1 0],'LabelVerticalAlignment', 'top')
xline(2887,'--',{'pixel = 2887    579nm','5.341 mm'},'Color',[0.9882 1 0],'LabelVerticalAlignment', 'bottom')

simHg = [2.9824 3.3130 3.5701 4.4889 4.7668]; %polohy spicek ze simulace (relativni vuci 0.r)[mm]
simHg = [3.0866 3.4288 3.6948 4.6458 4.9334]; %toto je s naměřenou hodnotou f'=31.0485mm
simHg_kor = simHg + 0.4237; % korekce, aby byly 0. řády z kamery i ze simulace na stejném místě(+ 0.1055 pro korekci na 365nm), je to nelinearni, asi kvuli cocce, mozna korekce?
simHg_pix = simHg_kor/pix_size;

xline(simHg_pix(1),'-','Color',[0.3804 0 0.3804])
xline(simHg_pix(2),'-','Color',[0.5098 0 0.7843])
xline(simHg_pix(3),'-','Color',[0.1137 0 1])
xline(simHg_pix(4),'-','Color',[0.5882 1 0])
xline(simHg_pix(5),'-','Color',[0.9882 1 0])

figure(4)
scatter(HgBarvy,HgPolohy(2:end),'red','filled')
hold on
scatter(HgBarvy,simHg_pix,'blue','filled')
grid on
scatter(589.262,2941,'yellow','filled')
fplot(@(lambda) 4.632*lambda + 205.5, [365 590],'--r')
fplot(@(lambda) 4.509*lambda + 194.2, [365 579],'--b')
xlabel('lambda [nm]')
ylabel('pos [pix]')
title('Pozice špiček pix = f(lambda)    -   simulace vs. skutečnost (Hg lampa)')
legend('přípravek MK2', 'simulace','validace Na','Location','northwest')

figure(5)

MK2_Na_combined = zeros(3036,4024,'uint8');
MK2_Na_combined(:,1:300) = MK2_Na0(:,1:300);
MK2_Na_combined(:,850:3030) = MK2_Na1(:,850:3030);
MK2_Na_combined(985:2120,3700:3780) = MK2_Na2(985:2120,3700:3780);

rotatedNa = imrotate(MK2_Na_combined,0.7792,'crop');
imshow(rotatedNa)

%Na doublet: D1=589.529nm ; D2=588.995nm

figure(6)
combinedNaHg = zeros(3036,4024,'uint8');
combinedNaHg(1846:3036,14:4024) = rotatedNa(1010:2200,1:4011);
combinedNaHg(100:860,:) = rotatedHg(790:1550,:);
imshow(combinedNaHg)

figure(7)
imshow(combinedNaHg)
hold on
xline(229,'--','Color',[1 1 1])
xline(2941,'--','Color',[1 0.8863 0])
xline(2851,'-','Color',[1 0.8863 0])
xline(2853,'-','Color',[1 0.8863 0])

simNa = [589.529 588.995]; %polohy spicek ze simulace (relativni vuci 0.r)[mm]
simNa_kor = simNa + 0.4237;
simNa_pix = simNa_kor/pix_size;

