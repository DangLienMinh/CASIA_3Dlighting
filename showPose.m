function showPose(im, align, shp)
im = im(:,:,1:3);
P = align.P;
R = align.R;
shpp=[shp,ones(size(shp,1),1)];
clr = [0; 255; 0];      % ���Ƶ�����ɫ
tex = repmat(clr, size(shpp,1), 1);     
% tex = ones(size(shpp, 1)*3, 1)*255;     
im_re=reProjection(shpp,tex,im,P);     %ͶӰ���ƣ�ϡ�裩��ʾЧ�����ٶȽϿ�
% [im_re,Zc_re]=Rendering(X,reshape(tex, [ 3 numel(tex)/3])',im,K,R,t,model.tl);  % denseͶӰ��ʾЧ�����ٶȽ�����
figure;
imshow(im_re);
% �� ����� ͶӰ��ָʾpose
R1 = [1 0 0; 0 -1 0; 0 0 1];        % �����вο�correction3.m�е���Ӧλ��
theta = 11.83;         
R2 = [1 0 0; 0 cosd(theta) -sind(theta); 0 sind(theta) cosd(theta)];    
rot = R1\R/R2;
loc    = [70 70]; % where to draw head pose
l = 60;
po = [0,0,0; l,0,0; 0,l,0; 0,0,l];
p2D = po*rot(1:2,:)';
hold on;
plot([p2D(1,1) p2D(2,1)]+loc(1),[p2D(1,2) p2D(2,2)]+loc(2), 'r');
plot([p2D(1,1) p2D(3,1)]+loc(1),[p2D(1,2) p2D(3,2)]+loc(2), 'g');
plot([p2D(1,1) p2D(4,1)]+loc(1),[p2D(1,2) p2D(4,2)]+loc(2), 'b');