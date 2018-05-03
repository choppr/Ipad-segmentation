clc
clear 
clear all
close all

I1 = imread('ipad2.jpg');
I = I1;
figure 
imshow(I)
I = rgb2gray(I1);
figure, imshow(I), title('original image in grayscale');

%%
[~, threshold] = edge(I, 'sobel');
fudgeFactor = .5;
BWs = edge(I,'sobel', threshold * fudgeFactor);
figure, imshow(BWs), title('binary gradient mask');

%%
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
%%
BWsdil = imdilate(BWs, [se90 se0]);BWdfill = imfill(BWsdil, 'holes');
% figure, imshow(BWdfill);
title('binary image with filled holes');
figure, imshow(BWsdil), title('dilated gradient mask');
%%
BWnobord = imclearborder(BWdfill, 4);
figure, imshow(BWnobord), title('cleared border image');
%%
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
figure, imshow(BWfinal), title('segmented image');

% mask = BWfinal;
% create a label image, where all pixels having the same value
% belong to the same object, example
% figure
labels = bwlabel(BWfinal);
% get the label at point (200, 200)
id = labels(200, 300);
% get the mask containing only the desired object
mask = (labels == id);
% imshow(mask);

%%
im=I1;
[imWidth imHeight] = size(I);

mask1 = im2uint8(mask) - 254;
BW3 = im.*repmat(mask1,[1 1 3]);

numpoints = 50;
x = randperm(imWidth,numpoints);
y = randperm(imHeight,numpoints);

%finding corners of the mask
C = corner(mask,'Harris',4);
OutputC = [0 400; 600 0; 600 400; 0 0];
figure, imshow(mask), title('corners detected'), hold on
plot(C(:,1), C(:,2),'b*');

%using corners from harris detector to transform segmented image to perfect
%square
plot(x, y,'r*');
a = [1:numpoints]'; b = num2str(a); c = cellstr(b);
text(x+5, y+10, c);
Tform2 = cp2tform(C,OutputC,'projective');
[iout, xdata, ydata] = imtransform(BW3,Tform2);
figure, imshow(iout), title('segmented ipad with color');