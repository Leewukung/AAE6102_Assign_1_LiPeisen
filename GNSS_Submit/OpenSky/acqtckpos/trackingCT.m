%             function  [TckResultCT, CN0_Eph] = trackingCT(file,signal,track,Acquired)
% %Purpose:
% %   Perform signal tracking using conventional DLL and PLL
% %Inputs:
% %	file        - parameters related to the data file to be processed
% %	signal      - parameters related to signals,a structure
% %	track       - parameters related to signal tracking 
% %	Acquired    - acquisition results
% %Outputs:
% %	TckResultCT	- conventional tracking results, e.g. correlation values in 
% %                   inphase prompt (P_i) channel and in qudrature prompt 
% %                   channel (P_q), etc.
% %--------------------------------------------------------------------------
% %                           SoftXXXGPS v1.0
% % 
% % Copyright (C) X X
% % Written by X X
% 
% TckResultCT = struct();  % 初始化空结构体
% 
% % 或者如果知道有多少个卫星，可以使用类似如下的方式提前初始化：
% % TckResultCT(length(Acquired.sv)) = struct('P_i', [], 'P_q', [], 'E_i', [], 'E_q', [], ...);
% 
% %%
% Spacing = [-track.CorrelatorSpacing 0 track.CorrelatorSpacing];
% 
% [tau1code, tau2code] = calcLoopCoef(track.DLLBW,track.DLLDamp,track.DLLGain);
% [tau1carr, tau2carr] = calcLoopCoef(track.PLLBW,track.PLLDamp,track.PLLGain);
% 
% datalength = track.msToProcessCT;
% delayValue = zeros(length(Acquired.sv),datalength);
% 
% 
% svlength    = length(Acquired.sv);
% snrIndex	= ones(1,svlength);
% K           = 20;
% flag_snr    = ones(1,svlength); % flag to calculate C/N0
% index_int   = zeros(1,svlength);
% pdi     = 1;%track.pdi; % To decode eph., 1ms T_coh is used. 
% sv  = Acquired.sv;
% 
% for svindex = 1:length(Acquired.sv)
%     remChip = 0;
%     remPhase=0;
%     remSample = 0;
%     carrier_output=0; 
%     carrier_outputLast=0;
%     PLLdiscriLast=0;
%     code_output=0;
%     code_outputLast=0;
%     DLLdiscriLast=0;
%     Index = 0;
%     AcqDoppler = Acquired.fineFreq(svindex)-signal.IF;
%     AcqCodeDelay = Acquired.codedelay(svindex);
% 
%     Codedelay = AcqCodeDelay;
%     codeFreq = signal.codeFreqBasis;
%     carrierFreqBasis = Acquired.fineFreq(svindex);
%     carrierFreq = Acquired.fineFreq(svindex);
% 
%     % set the file position indicator according to the acquired code delay
% %     fseek(file.fid,(signal.Sample-AcqCodeDelay-1+file.skip*signal.Sample)*file.dataPrecision*file.dataType,'bof');  %
%     fseek(file.fid,(signal.Sample-AcqCodeDelay+1 + file.skip*signal.Sample)*file.dataPrecision*file.dataType,'bof');  %  29/04/2020
% %     fseek(file.fid,(AcqCodeDelay-1+file.skip*signal.Sample)*file.dataPrecision*file.dataType,'bof');  %
% 
%     Code = generateCAcode(Acquired.sv(svindex));
%     Code = [Code(end) Code Code(1)];
% 
%     h = waitbar(0,['Ch:',num2str(svindex),' Please wait...']);
% 
%     for IndexSmall = 1: datalength 
%         waitbar(IndexSmall/datalength)
%         Index = Index + 1;
% 
% 
%         remSample = ((signal.codelength-remChip) / (codeFreq/signal.Fs));
%         numSample = round((signal.codelength-remChip)/(codeFreq/signal.Fs));%ceil
%         delayValue(svindex,IndexSmall) = numSample - signal.Sample;
% 
%         if file.dataPrecision == 2
%             rawsignal = fread(file.fid,numSample*file.dataType,'int16')'; 
% %             rawsignal = rawsignal(1:2:length(rawsignal)) + 1i*rawsignal(2:2:length(rawsignal));% For NSL STEREO LBand only
%             sin_rawsignal = rawsignal(1:2:length(rawsignal));
%             cos_rawsignal = rawsignal(2:2:length(rawsignal));
%             rawsignal0DC = sin_rawsignal - mean(sin_rawsignal) + 1i*(cos_rawsignal-mean(cos_rawsignal));
%         else
%             rawsignal0DC = fread(file.fid,numSample*file.dataType,'int8')';
%             if file.dataType == 2
%             rawsignal0DC = rawsignal0DC(1:2:length(rawsignal0DC)) + 1i*rawsignal0DC(2:2:length(rawsignal0DC));% For NSL STEREO LBand only 
%             end
%         end
% 
%         t_CodeEarly    = (0 + Spacing(1) + remChip) : codeFreq/signal.Fs : ((numSample -1) * (codeFreq/signal.Fs) + Spacing(1) + remChip);
%         t_CodePrompt   = (0 + Spacing(2) + remChip ) : codeFreq/signal.Fs : ((numSample -1) * (codeFreq/signal.Fs) + Spacing(2) + remChip);
%         t_CodeLate     = (0 + Spacing(3) + remChip) : codeFreq/signal.Fs : ((numSample -1) * (codeFreq/signal.Fs) + Spacing(3) + remChip);
%         CodeEarly      = Code(ceil(t_CodeEarly) + 1);
%         CodePrompt     = Code(ceil(t_CodePrompt) + 1);
%         CodeLate       = Code(ceil(t_CodeLate) + 1);
%         remChip   = (t_CodePrompt(numSample) + codeFreq/signal.Fs) - signal.codeFreqBasis*signal.ms;
% 
%         CarrTime = (0 : numSample)./signal.Fs;
%         Wave     = (2*pi*(carrierFreq .* CarrTime)) + remPhase ;  
%         remPhase =  rem( Wave(numSample+1), 2*pi); 
%         carrsig = exp(1i.* Wave(1:numSample));
%         InphaseSignal    = imag(rawsignal0DC .* carrsig);
%         QuadratureSignal = real(rawsignal0DC .* carrsig);
% 
%         E_i  = sum(CodeEarly    .*InphaseSignal);  E_q = sum(CodeEarly    .*QuadratureSignal);
%         P_i  = sum(CodePrompt   .*InphaseSignal);  P_q = sum(CodePrompt   .*QuadratureSignal);
%         L_i  = sum(CodeLate     .*InphaseSignal);  L_q = sum(CodeLate     .*QuadratureSignal);
% 
% 
% 
% 
%         % Calculate CN0
%         flag_snr(svindex)=1;
%         if (flag_snr(svindex) == 1)
%             index_int(svindex) = index_int(svindex) + 1;
%             Zk(svindex,index_int(svindex)) = P_i^2 + P_q^2;
%             if mod(index_int(svindex),K) == 0
%                 meanZk  = mean(Zk(svindex,:));
%                 varZk   = var(Zk(svindex,:));
%                 NA2     = sqrt(meanZk^2-varZk);
%                 varIQ   = 0.5 * (meanZk - NA2);
%                 CN0_Eph(snrIndex(svindex),svindex) =  abs(10*log10(1/(1*signal.ms*pdi) * NA2/(2*varIQ)));
%                 index_int(svindex)  = 0;
%                 snrIndex(svindex)   = snrIndex(svindex) + 1;
%             end
%         end
% 
%         % DLL
%         E               = sqrt(E_i^2+E_q^2);
%         L               = sqrt(L_i^2+L_q^2);
%         DLLdiscri       = 0.5 * (E-L)/(E+L);
%         code_output     = code_outputLast + (tau2code/tau1code)*(DLLdiscri - DLLdiscriLast) + DLLdiscri* (0.001/tau1code);
%         DLLdiscriLast   = DLLdiscri;
%         code_outputLast = code_output;
%         codeFreq        = signal.codeFreqBasis - code_output;
% 
%         % PLL
%         PLLdiscri           = atan(P_q/P_i) / (2*pi);
%         carrier_output      = carrier_outputLast + (tau2carr/tau1carr)*(PLLdiscri - PLLdiscriLast) + PLLdiscri * (0.001/tau1carr);
%         carrier_outputLast  = carrier_output;  
%         PLLdiscriLast       = PLLdiscri;
%         carrierFreq         = carrierFreqBasis + carrier_output;  % Modify carrier freq based on NCO command
% 
%         % Data Record
%         TckResultCT(Acquired.sv(svindex)).P_i(Index)            = P_i;
%         TckResultCT(Acquired.sv(svindex)).P_q(Index)            = P_q;
%         TckResultCT(Acquired.sv(svindex)).E_i(Index)            = E_i;
%         TckResultCT(Acquired.sv(svindex)).E_q(Index)            = E_q;
%         TckResultCT(Acquired.sv(svindex)).L_i(Index)            = L_i;
%         TckResultCT(Acquired.sv(svindex)).L_q(Index)            = L_q;
%         TckResultCT(Acquired.sv(svindex)).PLLdiscri(Index)      = PLLdiscri;
%         TckResultCT(Acquired.sv(svindex)).DLLdiscri(Index)      = DLLdiscri;
%         TckResultCT(Acquired.sv(svindex)).codedelay(Index)      = Codedelay + sum(delayValue(1:Index));
%         TckResultCT(Acquired.sv(svindex)).remChip(Index)        = remChip;
%         TckResultCT(Acquired.sv(svindex)).codeFreq(Index)       = codeFreq;  
%         TckResultCT(Acquired.sv(svindex)).carrierFreq(Index)    = carrierFreq;  
%         TckResultCT(Acquired.sv(svindex)).remPhase(Index)       = remPhase;
%         TckResultCT(Acquired.sv(svindex)).remSample(Index)      = remSample;
%         TckResultCT(Acquired.sv(svindex)).numSample(Index)      = numSample;
%         TckResultCT(Acquired.sv(svindex)).delayValue(Index)     = delayValue(svindex,IndexSmall);
%         TckResultCT(Acquired.sv(svindex)).absoluteSample(Index)  = ftell(file.fid); 
%         TckResultCT(Acquired.sv(svindex)).codedelay2(Index)       = mod( TckResultCT(Acquired.sv(svindex)).absoluteSample(Index)/(file.dataPrecision*file.dataType),signal.Fs*signal.ms);
%     end
%     close(h);
% end % end for
% 
% save(['TckResultCT_', file.fileName, '.mat'], 'TckResultCT');
% 
% 

function [TckResultCT, CN0_Eph] = trackingCT(file, signal, track, Acquired)
%Purpose:
%   Perform signal tracking using conventional DLL and PLL
%Inputs:
%   file        - parameters related to the data file to be processed
%   signal      - parameters related to signals,a structure
%   track       - parameters related to signal tracking 
%   Acquired    - acquisition results
%Outputs:
%   TckResultCT - conventional tracking results, e.g. correlation values in 
%                 inphase prompt (P_i) channel and in qudrature prompt 
%                 channel (P_q), etc.
%--------------------------------------------------------------------------

% TckResultCT = struct();  % Initialize empty structure
TckResultCT = struct('P_i', [], 'P_q', [], 'E_i', [], 'E_q', [], 'L_i', [], 'L_q', [], 'PLLdiscri', [], 'DLLdiscri', [], 'codedelay', [], 'remChip', [], 'codeFreq', [], 'carrierFreq', [], 'remPhase', [], 'remSample', [], 'numSample', [], 'delayValue', [], 'absoluteSample', [], 'codedelay2', []);


Spacing = -0.6:0.1:0.6; % Define the spacing from -0.6 to 0.6 with a 0.1 interval


[tau1code, tau2code] = calcLoopCoef(track.DLLBW, track.DLLDamp, track.DLLGain);
[tau1carr, tau2carr] = calcLoopCoef(track.PLLBW, track.PLLDamp, track.PLLGain);

datalength = track.msToProcessCT;
delayValue = zeros(length(Acquired.sv), datalength);

svlength = length(Acquired.sv);
snrIndex = ones(1, svlength);
K = 20;
flag_snr = ones(1, svlength); % Flag to calculate C/N0
index_int = zeros(1, svlength);
pdi = 1; % To decode eph., 1ms T_coh is used. 
sv = Acquired.sv;

CN0_Eph = NaN * ones(svlength, datalength);  % 或者根据需要调整大小


for svindex = 1:length(Acquired.sv)
    remChip = 0;
    remPhase = 0;
    remSample = 0;
    carrier_output = 0; 
    carrier_outputLast = 0;
    PLLdiscriLast = 0;
    code_output = 0;
    code_outputLast = 0;
    DLLdiscriLast = 0;
    Index = 0;
    AcqDoppler = Acquired.fineFreq(svindex) - signal.IF;
    AcqCodeDelay = Acquired.codedelay(svindex);
    
    Codedelay = AcqCodeDelay;
    codeFreq = signal.codeFreqBasis;
    carrierFreqBasis = Acquired.fineFreq(svindex);
    carrierFreq = Acquired.fineFreq(svindex);
    
    % Set the file position indicator according to the acquired code delay
    fseek(file.fid, (signal.Sample - AcqCodeDelay + 1 + file.skip*signal.Sample) * file.dataPrecision * file.dataType, 'bof');
    
    Code = generateCAcode(Acquired.sv(svindex));
    Code = [Code(end) Code Code(1)];
    
    h = waitbar(0, ['Ch:', num2str(svindex), ' Please wait...']);
    
    for IndexSmall = 1:datalength
        waitbar(IndexSmall / datalength)
        Index = Index + 1;
        
        remSample = ((signal.codelength - remChip) / (codeFreq / signal.Fs));
        numSample = round((signal.codelength - remChip) / (codeFreq / signal.Fs)); % ceil
        delayValue(svindex, IndexSmall) = numSample - signal.Sample;
        
        if file.dataPrecision == 2
            rawsignal = fread(file.fid, numSample * file.dataType, 'int16')'; 
            sin_rawsignal = rawsignal(1:2:length(rawsignal));
            cos_rawsignal = rawsignal(2:2:length(rawsignal));
            rawsignal0DC = sin_rawsignal - mean(sin_rawsignal) + 1i * (cos_rawsignal - mean(cos_rawsignal));
        else
            rawsignal0DC = fread(file.fid, numSample * file.dataType, 'int8')';
            if file.dataType == 2
                rawsignal0DC = rawsignal0DC(1:2:length(rawsignal0DC)) + 1i * rawsignal0DC(2:2:length(rawsignal0DC)); % For NSL STEREO LBand only 
            end
        end
        
        % Early and Late code generation with the new spacing from -0.6 to 0.6
        t_CodeEarly = cell(1, length(Spacing));
        t_CodeLate = cell(1, length(Spacing));
        for i = 1:length(Spacing)
            t_CodeEarly{i} = (0 + Spacing(i) + remChip) : codeFreq / signal.Fs : ((numSample - 1) * (codeFreq / signal.Fs) + Spacing(i) + remChip);
            t_CodeLate{i} = (0 + Spacing(i) + remChip) : codeFreq / signal.Fs : ((numSample - 1) * (codeFreq / signal.Fs) + Spacing(i) + remChip);
        end
        
        remChip = (t_CodeEarly{end}(numSample) + codeFreq / signal.Fs) - signal.codeFreqBasis * signal.ms;
        
        CarrTime = (0 : numSample) ./ signal.Fs;
        Wave = (2 * pi * (carrierFreq .* CarrTime)) + remPhase;  
        remPhase = rem(Wave(numSample + 1), 2 * pi); 
        carrsig = exp(1i .* Wave(1:numSample));
        InphaseSignal = imag(rawsignal0DC .* carrsig);
        QuadratureSignal = real(rawsignal0DC .* carrsig);
        
        E_i = sum(t_CodeEarly{1} .* InphaseSignal);  
        E_q = sum(t_CodeEarly{1} .* QuadratureSignal);
        P_i = sum(t_CodeEarly{2} .* InphaseSignal);  
        P_q = sum(t_CodeEarly{2} .* QuadratureSignal);
        L_i = sum(t_CodeLate{1} .* InphaseSignal);  
        L_q = sum(t_CodeLate{1} .* QuadratureSignal);
        
        % Calculate CN0
        flag_snr(svindex) = 1;
        if (flag_snr(svindex) == 1)
            index_int(svindex) = index_int(svindex) + 1;
            Zk(svindex, index_int(svindex)) = P_i^2 + P_q^2;
            if mod(index_int(svindex), K) == 0
                meanZk = mean(Zk(svindex, :));
                varZk = var(Zk(svindex, :));
                NA2 = sqrt(meanZk^2 - varZk);
                varIQ = 0.5 * (meanZk - NA2);
                CN0_Eph(snrIndex(svindex), svindex) = abs(10 * log10(1 / (1 * signal.ms * pdi) * NA2 / (2 * varIQ)));
                index_int(svindex) = 0;
                snrIndex(svindex) = snrIndex(svindex) + 1;
            end
        end
        
        % DLL
        E = sqrt(E_i^2 + E_q^2);
        L = sqrt(L_i^2 + L_q^2);
        DLLdiscri = 0.5 * (E - L) / (E + L);
        code_output = code_outputLast + (tau2code / tau1code) * (DLLdiscri - DLLdiscriLast) + DLLdiscri * (0.001 / tau1code);
        DLLdiscriLast = DLLdiscri;
        code_outputLast = code_output;
        codeFreq = signal.codeFreqBasis - code_output;
        
        % PLL
        PLLdiscri = atan(P_q / P_i) / (2 * pi);
        carrier_output = carrier_outputLast + (tau2carr / tau1carr) * (PLLdiscri - PLLdiscriLast) + PLLdiscri * (0.001 / tau1carr);
        carrier_outputLast = carrier_output;  
        PLLdiscriLast = PLLdiscri;
        carrierFreq = carrierFreqBasis + carrier_output;  % Modify carrier freq based on NCO command
        
        % Data Record
        TckResultCT(Acquired.sv(svindex)).P_i(Index) = P_i;
        TckResultCT(Acquired.sv(svindex)).P_q(Index) = P_q;
        TckResultCT(Acquired.sv(svindex)).E_i(Index) = E_i;
        TckResultCT(Acquired.sv(svindex)).E_q(Index) = E_q;
        TckResultCT(Acquired.sv(svindex)).L_i(Index) = L_i;
        TckResultCT(Acquired.sv(svindex)).L_q(Index) = L_q;
        TckResultCT(Acquired.sv(svindex)).PLLdiscri(Index) = PLLdiscri;
        TckResultCT(Acquired.sv(svindex)).DLLdiscri(Index) = DLLdiscri;
        TckResultCT(Acquired.sv(svindex)).codedelay(Index) = Codedelay + sum(delayValue(1:Index));
        TckResultCT(Acquired.sv(svindex)).remChip(Index) = remChip;
        TckResultCT(Acquired.sv(svindex)).codeFreq(Index) = codeFreq;  
        TckResultCT(Acquired.sv(svindex)).carrierFreq(Index) = carrierFreq;  
        TckResultCT(Acquired.sv(svindex)).remPhase(Index) = remPhase;
        TckResultCT(Acquired.sv(svindex)).remSample(Index) = remSample;
        TckResultCT(Acquired.sv(svindex)).numSample(Index) = numSample;
        TckResultCT(Acquired.sv(svindex)).delayValue(Index) = delayValue(svindex, IndexSmall);
        TckResultCT(Acquired.sv(svindex)).absoluteSample(Index) = ftell(file.fid); 
        TckResultCT(Acquired.sv(svindex)).codedelay2(Index) = mod(TckResultCT(Acquired.sv(svindex)).absoluteSample(Index) / (file.dataPrecision * file.dataType), signal.Fs * signal.ms);
    end
    close(h);
end % End for

save(['TckResultCT_', file.fileName, '.mat'], 'TckResultCT');
