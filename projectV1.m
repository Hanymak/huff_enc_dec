clear;
clc;%%clear old variables so as not to make confusion
tic;%% calculate time
%%Encoding
x=(rgb2gray(imread('C:\Users\mido0\Desktop\hany_mina.jpg')));%% image to rgb

x = imresize(x,0.1);%% resizing to 0.1 of the image

input_image=x; %%input image after resize
[symb_freq,symb_value]=imhist(input_image);% getting the repetition in each gray lavel and corresponding value


input_image_vector=symb_freq;
[image_vector_ordered,image_indecies] = sort(input_image_vector,'descend');%% sorting in descending order the frequency of gray levels with saving indixes 

symb_value_sorted=symb_value(image_indecies);%%sorting the symbols values in same as the highest frequency to replace them on decoding
image_vector_ordered_prob=image_vector_ordered./sum(input_image_vector);%%summation to get the max and divide by it to get each symbol probability


r=2;
%this while loop to check if K is integer and if not to add zero
while(1)
    symbol_size_temp=length(image_vector_ordered_prob);%%using temp size as k might not be integer
    if(mod(symbol_size_temp-r,r-1))
        image_vector_ordered_prob(end+1)=0;%% adding zero probability at the end
    else 
        break;
    end
end

symbol_size=length(image_vector_ordered_prob);%getting number of symbols
k=(symbol_size-r)/(r-1);%% k to know number of iterations needed
j=1;%% to save each new iteration in new column 

for i=symbol_size:-1:symbol_size-k+1
    image_vector_ordered_prob(1:i-1,j+1)=image_vector_ordered_prob(1:i-1,j);%take all probilities to the next stage except last probility
    image_vector_ordered_prob(i-1,j+1)=image_vector_ordered_prob(i-1,j)+image_vector_ordered_prob(i,j);%add the last two probolities of pervious stage
    image_indecies(1:symbol_size,j+1)=(1:symbol_size);%%setting indecies in order from 1>symbol_size and later changing them to set new prob if repeated on top
    for n=1:symbol_size
        if(image_vector_ordered_prob(i-1,j+1)>=image_vector_ordered_prob(n,j+1))%% searching for equaivalent or smaller probility than the last added two probilities
            image_indecies(:,j+1)=[image_indecies(1:n-1,j+1);image_indecies(i-1,j+1);image_indecies(n:end-1,j+1)];%inserting it's index on top of repeated probility or on top of smaller ones

            break;
        
        end
    end
    [image_vector_ordered_prob(:,j+1),~] = sort(image_vector_ordered_prob(:,j+1),'descend');%sort the probilities in descending order as we already ordered the indecies
    [~,image_indecies_sort(:,j+1)]=sort(image_indecies(:,j+1));%% saving the indecies in ordered way to retrive them 
   
    j=j+1;
end

myhuff=cell(symbol_size,symbol_size);%% making matrix of cells to save vector in form of [0,0,1,1] in each cell of a matrix
myhuff(:,:)={0};%setting all values to zero
myhuff(2,k+1)={1};%setting second last stage prob to 1
o=2;

for j=symbol_size:-1:symbol_size-k+1
     myhuff(1:o,j-2)=myhuff(image_indecies_sort(1:o,j-1),j-1);%%remapping using indecies the coded values of preivous prob on their old values
     temp=myhuff{o,j-2};%% saving this stage last coded values
     myhuff(o,j-2)={[temp,0]};%% adding 0 to the last -1 code
     
     myhuff(o+1,j-2)={[temp,1]};%% adding 1 to the last code
     o=o+1;
end
%stream=[];
image_size=(size(x,1)*size(x,2));
input_image_vector_all=input_image(:);
for i=1:image_size
    
    st{i}=myhuff{find(symb_value_sorted==input_image_vector_all(i))}; %replacing the values in a code-word to send them
end
stream=[st{1:end}];%setting them in a vector
%%Decoding
i=length(myhuff{1,1});%% getting the minmuim length if bits in a sent stream
length_of_first_huff=i;%%saving the minmuim length if bits in a sent stream
begin_of_stream=1;%% to be changed after a stream is found

[a,b]=size(input_image);
compression_ratio_1=100*length(stream)/(a*b*8);
matching=0;%to flag when a matching stream is found

p=1;
op=1;
average_code_length=0;
for leng=1:symbol_size
   
    average_code_length=average_code_length+(image_vector_ordered_prob(leng,1).*length(myhuff{leng,1}));
end
compression_ratio_2=8/average_code_length;%%compression ratio in other way


while (1)
   while(op<=symbol_size)
    
       i=length(myhuff{op,1});
    if isequal({[stream(begin_of_stream:begin_of_stream+i-1)]} , [myhuff(op)])%%check if stream bits matches the code word
        
       matching=1;
       
       begin_of_stream=begin_of_stream+i;%%change stream beginning
       % i=i+length_of_first_huff; %% add minimum length
       recevied_symbol(p)=symb_value_sorted(op);%save the symbol found from the dicitionary
       p=p+1;
    break;
    end
        op=op+1;
   
   end
   op=1;
   if matching
      
       
       matching=0;
        if  begin_of_stream-1>=length(stream)%%if stream lasted break the bigger while loop
            break;
        end
   else
     
      
      
            i=i+1;
       
   end
   
   
   
       
           
end
reshaped_image=reshape(recevied_symbol,size(input_image));%shape the image
 if isequal(reshaped_image , x)%% checking if the input image and out have the same graylevels 
    figure, imshow(x) ,xlabel('input')
    figure , imshow( mat2gray(reshaped_image)),xlabel('output');
 else
     error('image not correct')
 end







toc;