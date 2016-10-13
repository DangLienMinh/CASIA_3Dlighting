function result = correction(im, fov, pt, draw, pred)
% based on correction2.m, pruned to only output alignment parameters.
if nargin < 5 pred = []; end
if nargin < 4 draw = 0; end
if nargin < 2 fov = 53; end
im = im(:,:,1:3);

if isempty(pred)
    [DM,TM,option] = xx_initialize;
    [pred,pose] = xx_track_detect(DM,TM,im,[],option);  % use intraFace detector to detect 49 facial landmarks
elseif all(pred(:) == 0)
    pred = [];
end
if isempty(pred)
    result = [];
    return;
end
% % index2 = [20 23 26 29 15 17 19 32 38]';
% index2=[11:14 15 17 19 20:31 32 35 38 41];
index2 = 1:49;
if draw == 1
    figure;
    imshow(im);
    hold on;
    plot(pred(index2,1), pred(index2,2), 'r.');%ͼ��ƽ������,������Ͻǣ�ˮƽΪx�ᣬ��ֱΪy��
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
[P,K,R,t,mse,angle]=ComputeProjection_fix_intrinsic(X, x, K, 0.05, 500);      % R���ǵ�������ת��������z��ķ�ת����Ϊ��������Ϊ����ϵ���������ϵΪ����
% h = size(im, 1); w = size(im, 2);     % ��Ⱦ��groundtruth pose
% gamma = -15*pi/180;
% Rx = [1, 0, 0;...
%     0, cos(gamma), -sin(gamma);...
%     0, sin(gamma), cos(gamma)];
% R = Rx; R(:, 3) = -R(:, 3);
% t = [0; 0; 800];
% fov = 25;
% f = w/2/tand(fov/2);
% K = [f 0 w/2; 0 f h/2; 0 0 1];
% P = K*[R t];

result.P = P;
result.K = K;
result.R = R;
result.t = t;
result.mse = mse;
result.angle = angle;   % angle�������������������ϵ��Cw&Cc����������ϵʱ���������ϵת����������ϵ���ΰ���x, y, zת���ĽǶȡ�
% %% �����Ż�
% K0 = K
% t0 = t
% for i = 1:50
%     ff(i) = K(1,1);
%     msee(2*i-1) = mse;
%     [P,K,R,t,mse]=ComputeProjection_fix_R(X, x, K, R, t, 0.05, 500); 
%     msee(2*i) = mse;
%     [P,K,R,t,mse]=ComputeProjection_fix_intrinsic(X, x, K, 0.05, 500);
% end
% shpp=[shp,ones(size(shp,1),1)];
% im_re=reProjection(shpp,tex,im,P);     %ͶӰ���ƣ�ϡ�裩��ʾЧ�����ٶȽϿ�
% % [im_re,Zc_re]=Rendering(X,reshape(tex, [ 3 numel(tex)/3])',im,K,R,t,model.tl);  % denseͶӰ��ʾЧ�����ٶȽ�����
% figure;
% imshow(im_re);
% figure;
% plot(ff);
% figure, plot(msee);
%% ����plyģ��
% shp_cam = R * shp';
% shp_cam(3,:)=-shp_cam(3,:); %�������ϵ�����ֹ�����ply����ʾʱ��Ҫ��ת
% plywrite('2.ply', shp_cam, tex, tl );