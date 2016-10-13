function v = lightingEstimate(im, draw, align, M, shp, tl, Gamma)
if nargin < 7 Gamma = []; end   % Gamma correction
if nargin < 4 M = []; end
if nargin < 2 draw = 0; end

if ~isempty(Gamma)
    im = invGamma(im, Gamma);
end
h = size(im, 1); w = size(im, 2);
P = align.P;
R = align.R;
% compute trangle center normals and intensity 
[normal,~] = compute_normal(shp,tl);
R1 = R;
R1(3,:) = -R(3,:);
normal = R1*normal;   % normal vectors in a coordinate system facing right to the camera.
normal = normal';
flag = [];
for i = 1:size(normal, 1)      % �ҵ�������zΪ��������ά�㣬��Щ��һ���Ǳ��ڵ��ĵ㣬��������ɾ����������Ϊ��zbuffer�����һ�������㷨�����ַ���Ӧ��ֻ�Էǰ����������á����������ǰ���ڵ��Ĳ����á�
    if normal(i, 3) < 0
        flag = [flag; i];
    end
end
normal(flag, :) = [];
shp(flag, :) = [];
if draw == 1
    reProjectionNormal(shp, normal, 0, P, im);     %ͶӰ�����������Լ���������������plot
end
vt2d = (P*[shp, ones(size(shp,1), 1)]')';
vt2d = vt2d./repmat(vt2d(:,3), 1, 3);
vt2d = vt2d(:,1:2);
vt2d(:,2)=vt2d(:,2)-h;
temp= [0 1;-1 0];%ת��Ϊ��������
vt2d = round(vt2d*temp);
greyf = zeros(size(shp, 1), 3);
ind = sub2ind(size(im), vt2d(:,1), vt2d(:,2)); 
for i = 1:3
   temp = im(:,:,i);
   greyf(:,i) = temp(ind);
end
if isempty(M)
    M = Mcoeff(normal');
else
    if size(M, 2) == 9          % ���������ϵ� transfer coefficients
        M(flag, :) = [];
    elseif size(M, 2) == 3      % ������Ǹ� Farid's ������Ȩ��Ȩ�أ��� Farid ������������
        weight = M(:, 2);       % ֻ���� G ͨ����ϵ��
        weight(flag, :) = [];
        M = Mcoeff(normal');
        M = repmat(weight, 1, 9).*M;
    end
end
b = greyf;
v = zeros(9, 3);    % This calculated lighting direction's coordinate system is the world coordinate attached to the head. That's x to the right, y to the up, z to outside.
for i = 1:3
    v(:, i) = (M'*M)\M'*b(:, i);
end