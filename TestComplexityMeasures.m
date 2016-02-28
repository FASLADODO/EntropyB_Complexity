clear;clc
format long;
path = 'C:\Users\Alveuz\Documents\GitHub\EntropyB_Complexity\';

SolarFlaresData         = 'SolarFlaresData.mat';
BikeSharingData         = 'BikeSharingData.mat';
HouseElecCnsmptData     = 'HouseHoldElectricConsumption.mat';
% Load datasets containing UCI's data sets
% In this example SolarFlares and Household electric consumption are
% matrix while Bike sharing data for hour and day are two separated vectors
% for convinience.

complexityType = 1; %Discrete complexity measures
% complexityType = 2; %Continuous complexity measures

switch complexityType
    case 1
        % dataSet = 1; load([path SolarFlaresData]);%Flares, contains 
        % dataSet = 2; load([path BikeSharingData]);%Bike Sharing
        dataSet = 3; load([path HouseElecCnsmptData]);%Household electric consumption
        switch dataSet
            case 1
                noOfStates  = 30;%Number of states of the system
                Emrgnc      = zeros(3,1);
                SlfRgnztn   = zeros(3,1);
                Cmplxty     = zeros(3,1);
                %SolarFlares(:,1) contains C-Class, (:,2) M-Class, (:,3)
                %X-Class
                for i=1:3
                    pmfSample   = SolarFlares(:,i);
                    [Emrgnc(i,1), SlfRgnztn(i,1), Cmplxty(i,1)] = ...
                        DiscreteComplexityMeasures(pmfSample, noOfStates);
                end
            case 2
                noOfStates  = 30;%Number of states of the system
                Emrgnc      = zeros(2,1);
                SlfRgnztn   = zeros(2,1);
                Cmplxty     = zeros(2,1);
                %BikeSDDay(:,1) contains a counter of Bikes used per Day, 
                %BikeSDHour(:,2) contains a counter of Bikes used per Hour
                for i=1:2
                    switch i
                        case 1
                            pmfSample   = BikeSDDay(:,1);
                        case 2
                            pmfSample   = BikeSDHour(:,2);
                    end
                    [Emrgnc(i,1), SlfRgnztn(i,1), Cmplxty(i,1)] = ...
                        DiscreteComplexityMeasures(pmfSample, noOfStates);
                end
            case 3
                noOfStates  = 30;%Number of states of the system
                Emrgnc      = zeros(2,1);
                SlfRgnztn   = zeros(2,1);
                Cmplxty     = zeros(2,1);
                %Household electric consumption(:,1) contains Global house
                %consumption, (:,2) Kitchen consumption
                for i=1:2
                    pmfSample   = HouseholdPowerConsumption(:,i);
                    [Emrgnc(i,1), SlfRgnztn(i,1), Cmplxty(i,1)] = ...
                        DiscreteComplexityMeasures(pmfSample, noOfStates);
                end
        end
    case 2
        %% Continuous Complexity Measures
        % This is an example on how to use the continuous complexity
        % measures. In this, two probability density functions are
        % employed: Gaussian and Power-Law
        % Define the experimantal Setup MetaParameters
        distSampleSize  = 100000;
        distParamNum    = 10;
        %Probability Function
        % 1 = Gaussian Distribution
        % 2 = Power Law Distribution
        pdfType = 2;
        %Want to produce plots for distributions?
         plotPDFOn = 0;%Definetively NO
%        plotPDFOn = 1; %Yes, it would be amazing
        %% Create Probability Distribution Parameter Sequence
        switch pdfType
            case 1
                % Normal Distribution
                % Two Parameters, Mean (mu) and Standard Deviation (sigma)
                paramSeq        = 1:distParamNum; 
                % Create discrete integration sequence
                maxVal  = 100;
                minVal  = 0; 
                dtSeq   = linspace (minVal, maxVal, distSampleSize); 
                % Define Mean of the Normal Distribution(i.e. Mu=0)
                mu      = (maxVal - minVal)/2;
                %Delta increment for discrete Integration
                Delta       = (maxVal-minVal)/(distSampleSize);
                noOfStates  = 50;
                for i=1:distParamNum
                    % Define Sigma of the Normal Distribution
                    sigma   = paramSeq(1,i);
                    % Create the Normal PDF
                    gaussDist   = normpdf(dtSeq,mu,sigma);
                    switch plotPDFOn
                        case 1
                            figure(2);
                            plot(dtSeq, gaussDist, 'linewidth', i); 
                            hold on;
                        otherwise
                    end
                    % Temporarely save the distribution
                    pdfMatrix(:, i) = gaussDist(1,:);
                    % Calculate Differential Complexity Measures
                    [Emrgnc(i,1), SlfRgnztn(i,1), Cmplxty(i,1)] = ...
                        ContinuousComplexityMeasures(pdfMatrix(:, i),...
                        minVal, maxVal, distSampleSize,noOfStates);
                end
            case 2
                % Power-Law Distribution
                % Two Parameters, xmin and power exponent (alpha)
                paramSeqXmin    = 1:distParamNum;
                % paramSeqScale   = 1:distParamNum;
                % Create discrete integration sequence
                maxVal      = 100;
                minVal      = 10;
                noOfStates  = 50;
                for i=1:distParamNum
                    % Define the Power-Law Density Distribution Function
                    xmin        = paramSeqXmin(i);
                    dtSeq       = linspace (xmin, maxVal, distSampleSize);
                    alpha       = 5;
                    % Create the Power-Law PDF
                    rightHand   = ((alpha-1)/xmin);
                    leftHand    = (dtSeq(:)./xmin).^(-1*alpha);
                    pLawDist(:,i)   = rightHand*leftHand;
                    switch plotPDFOn
                        case 1
                            figure(2);
                            plot(pLawDist,'r', 'linewidth', (.1*(i-1)+1 ));
                            hold on;
                    end
                    [Emrgnc(i,1), SlfRgnztn(i,1), Cmplxty(i,1)] = ...
                        ContinuousComplexityMeasures(pLawDist(:, i),...
                        minVal, maxVal, distSampleSize,noOfStates);
                end
        end
end
ESC = [Emrgnc, SlfRgnztn, Cmplxty];
figure(8);
bar3(ESC)
% my_bar3(ESC,1)
disp('Bye Cruel World!!!')

