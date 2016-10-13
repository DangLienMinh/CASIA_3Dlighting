function result = correction3(im, draw, fov)
% ��ͬ��correction2.m fix intrinsic, estimate both R, t����
% correction3.m���������IntraFace�ṩ��pose�е�rot��fix��intrinsic & rotation,
% ֻestimate t���о����ַ��������Ч��Ҳ�ܺã����߸���
% clc;
% clear all;
% close all;
if nargin == 1
    draw = 0; 
    fov = 53;   % equal to f = max(size(im));
end
if nargin == 2
    fov = 53;
end
addpath('D:\allProjects\toolBox\toolbox_graph');
addpath('D:\allProjects\toolBox\xml_io_tools');
im = im(:,:,1:3);

[DM,TM,option] = xx_initialize;
[pred,pose] = xx_track_detect(DM,TM,im,[],option);
if isempty(pred)
    result = [];
    return;
end

% index2 = [20 23 26 29 15 17 19 32 38]';
index2=[11:14 15 17 19 20:31 32 35 38 41];
% index2 = 1:49;
if draw == 1
    figure;
    imshow(im);
    hold on;
    plot(pred(index2,1), pred(index2,2), 'r.');%ͼ��ƽ������,������Ͻǣ�ˮƽΪx�ᣬ��ֱΪy��
end
plyfile = 'D:\allProjects\3D from Image ww\BMM\default.ply';
ppfile = 'D:\allProjects\3D from Image ww\BMM\11_feature_points\default_picked_points.pp';
[shp, tl] = read_ply(plyfile);
xml = xml_read(ppfile);
pt = zeros(size(xml.point, 1), 3);      %û��3d��������һ��
for i = 1:size(pt, 1)
    pt(i, 1) = xml.point(i).ATTRIBUTE.x;
    pt(i, 2) = xml.point(i).ATTRIBUTE.y;
    pt(i, 3) = xml.point(i).ATTRIBUTE.z;
end
X = pt(index2, :);
h=size(im,1);
M = [1 0;0 -1];
% pred = marker;   % Hathaway_marked1493.jpg �ϵ�׼ȷ�ؼ���λ�ã���Hathaway_picked_marker��Ӧ��2d�㡣
pred = pred*M; %plot����->ͼ����������
pred(:,2)=pred(:,2)+h;%ԭ�����½ǣ�ˮƽx�ᣬ��ֱy��

%http://blog.csdn.net/b5w2p0/article/details/8804216
x=[pred(index2,:),ones(length(index2),1)];
X=[X,ones(size(X,1),1)];
%��֪�ڲ�������
% f = max(size(im)); 
% f = 1067;
f = max(size(im))/2/tand(fov/2);
u0 = size(im, 2)/2;
v0 = size(im, 1)/2;
K = [f 0 u0; 0 f v0; 0 0 1];
R1 = [1 0 0; 0 -1 0; 0 0 1];        % R1 �Ǵ�IntraFace�������ת�ο����꣨�� xx_track_detect ���ҵ�ע�ͣ����������ϵ�ı�
theta = 11.83;          % ������ǲ����ľ���ֵ����pbrt�и�����ͷ����IntraFace�����poseΪ����ǰ
R2 = [1 0 0; 0 cosd(theta) -sind(theta); 0 sind(theta) cosd(theta)];    % R2 ��Face Gen�����굽IntraFace���������������ı任��FaceGen����ͷ����΢΢̧��ġ�����
R = R1*pose.rot*R2;        % pose.rot��IntraFace�������������ϵ��IntraFace����Ĳο�����ı任

[P,K,R,t,mse]=ComputeProjection_fix_R_intrisic(X, x, K, R, 0.05, 500);      % R���ǵ�������ת��������z��ķ�ת����Ϊ��������Ϊ����ϵ���������ϵΪ����

result.P = P;
result.K = K;
result.R = R;
result.t = t;
result.mse = mse;
%%
if draw == 1
    shpp=[shp,ones(size(shp,1),1)];
    clr = [0; 255; 0];      % ���Ƶ�����ɫ
    tex = repmat(clr, size(shpp,1), 1);     
    % tex = ones(size(shpp, 1)*3, 1)*255;     
    im_re=reProjection(shpp,tex,im,P);     %ͶӰ���ƣ�ϡ�裩��ʾЧ�����ٶȽϿ�
    % [im_re,Zc_re]=Rendering(X,reshape(tex, [ 3 numel(tex)/3])',im,K,R,t,model.tl);  % denseͶӰ��ʾЧ�����ٶȽ�����
    figure;
    imshow(im_re);
    loc    = [70 70]; % where to draw head pose
    l = 60;
    po = [0,0,0; l,0,0; 0,l,0; 0,0,l];
    p2D = po*pose.rot(1:2,:)';
    hold on;
    plot([p2D(1,1) p2D(2,1)]+loc(1),[p2D(1,2) p2D(2,2)]+loc(2), 'r');
    plot([p2D(1,1) p2D(3,1)]+loc(1),[p2D(1,2) p2D(3,2)]+loc(2), 'g');
    plot([p2D(1,1) p2D(4,1)]+loc(1),[p2D(1,2) p2D(4,2)]+loc(2), 'b');
end