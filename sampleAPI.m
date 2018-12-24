% Test script for Z3Score.com RESTful API
% For documentation pertaining to the API please visit
% https://github.com/amiyapatanaik/z3score-api
% This script demonstrates the basic functionalities of the Z3Score
% API. The API can be accessed from any language
% to know more see: https://en.wikipedia.org/wiki/Representational_state_transfer
% Patents pending (c)-2016 Amiya Patanaik amiyain@gmail.com
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% Requires cfslib MATLAB library: https://github.com/neurobittechnologies/cfslib-MATLAB
%

% Main settings
% https is NOT supported, use http
serverURL = 'http://z3score.com/api/v1';
email = 'email@domain.com';
key = 'API_KEY';

%Download cfslib-MATLAB from https://github.com/neurobittechnologies/cfslib-MATLAB
addpath('cfslib-MATLAB');
addpath('cfslib-MATLAB/utilities');
addpath('cfslib-MATLAB/utilities/jsonlab');
addpath('cfslib-MATLAB/utilities/encoder');
clc

%check license
try
    response = loadjson(urlreadpost([serverURL '/check'],...
                                        {'email',email,'key',key}));
catch
    disp('Server is unreachable');
    return
end

if response.status == 0,
    disp('License check failed');
    disp(['Error message: ' response.message])
    return
end

disp(response.message);
fprintf('API Call limit (hourly): %d, Epoch limit (daily): %d\n',response.call_limit, response.epoch_limit);

% Path to sample EDF file
filepath = [pwd '/test.edf'];

%Read the raw data
disp('Reading raw EDF data');
tic;
[header, signalHeader, signalCell] = blockEdfLoad(filepath);
t = toc;
fprintf('Time taken %.3f seconds\n',t);
%Number of channels
N = numel(signalHeader);
%Now select only C3, C4, EoG-l and EoG-r channels
disp('Here are all the channels:');
for k=1:N,
    fprintf('%d: %s\n',k,signalHeader(k).signal_labels);
end
C3N = input('Please select the C3:A2 channel number: ');
C4N = input('Please select the C4:A1 channel number: ');
ELN = input('Please select the EOGl:A2 channel number: ');
ERN = input('Please select the EOGr:A1 channel number: ');
EM = input('Please select the bipolar EMG channel number: ');

%Find out sampling rate
samplingRateEEG = signalHeader(C3N).samples_in_record/header.data_record_duration;
samplingRateEOG = signalHeader(ELN).samples_in_record/header.data_record_duration;
samplingRateEMG = signalHeader(EM).samples_in_record/header.data_record_duration;
num_epochs = floor(size(signalCell{C3N},1)/samplingRateEEG/30);

%Convert raw stream to a CFS and write to a file
disp('Converting EDF data to CFS and saving in test.cfs');
tic;
%Convert raw PSG stream to CFS stream
stream = streamCFS_V2(signalCell{C3N}, signalCell{C4N}, signalCell{ELN}, signalCell{ERN}, signalCell{EM}, samplingRateEEG, samplingRateEOG, samplingRateEMG);
fileID = fopen('test.cfs','w');
fwrite(fileID,stream,'*uint8','ieee-le');
fclose(fileID);
t = toc;
fprintf('Time taken %.3f seconds\n',t);

%Now ask server to score the cfs file generated earlier 
disp('Scoring CFS stream');
%You can also read the CFS stream from file like this:
%f = fopen('test.cfs'); stream = fread(f,Inf,'*uint8'); fclose(f);
%as we already have the stream we won't read the CFS file again
tic;
try
    response = loadjson(urlreadpost([serverURL '/score'], ... 
        {'email',email,'key',key,'file',stream}));
catch
    disp('Server is unreachable');
    return
end
t = toc;

if response.status == 0,
    disp('Error scoring data.');
    disp(['Error message:' response.message])
    return
end

fprintf('Time taken %.3f seconds.\nAPI calls left (hourly limits): %d, Epochs left (daily limits): %d \n',t, response.calls_left, response.epochs_left);
%Automatic sleep scores
scores = response.message;
%Save the sleep scores
csvwrite('test_score.csv',response.message)
%Read expert sleep scores
expert = csvread('test_expert.csv');
expert = expert(1:num_epochs);

C = confusionmat(scores(:,1),expert);
fprintf('Auto scoring agreement with expert scorer: %.2f%%\n',sum(scores(:,1) == expert)*100/num_epochs);
kappa(C);

disp('Done');
