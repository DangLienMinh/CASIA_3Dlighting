function [P,K,R,t,mse, angle]=ComputeProjection_fix_intrinsic(X3d, x2d,K,lambda,maxiter)
xc = transpose(K\x2d');
xc = xc./repmat(xc(:, 3), 1, 3);
X=X3d; %X,xc err���������
X(:,3)=-X(:,3);%��������ϵΪ���֣��������ϵΪ���֣���Ҫһ��
% options = optimset('Algorithm','trust-region-reflective','MaxIter',maxiter);
options = optimset('Algorithm',{'levenberg-marquardt',lambda},'MaxIter',maxiter);       % LM�Ż���������С���˱��������䷨�úܶࡣ
[p, resnorm] = lsqnonlin(@(p) err(p,xc,X), [0,0,0,0,0,0.1],[],[],options);
% p = [0,0,0,0,0,1];
alpha = 10*p(1); beta = 10*p(2); gama = 10*p(3); t1 = 10*p(4)*10^round(log10(range(X(:,1))));...
        t2 = 10*p(5)*10^round(log10(range(X(:,2)))); t3 = 100*p(6)*10^round(log10(range(X(:,1))));     % ��Ϊ�������ϵ��ZΪX��Y��10��������ҲҪ��10��
% alpha = p(1)*10; beta = p(2)*10; gama = p(3)*10; t1 = p(4)*10^6; t2 = p(5)*10^6; t3 = p(6)*10^7;    %��ϵ�����൱�ڹ�һ�����ݵĶ�̬��Χ��
% alpha = p(1); beta = p(2); gama = p(3); t1 = p(4); t2 = p(5); t3 = p(6);
angle = [gama; beta; alpha];        % angle in radian
Rz = [cos(alpha), -sin(alpha), 0;...
    sin(alpha), cos(alpha), 0;...
    0, 0, 1];
Ry = [cos(beta), 0, sin(beta);...
    0, 1, 0;...
    -sin(beta), 0, cos(beta)];
Rx = [1, 0, 0;...
    0, cos(gama), -sin(gama);...
    0, sin(gama), cos(gama)];
%     R = [cos(alpha)*cos(gama)-cos(beta)*sin(alpha)*sin(gama), -cos(beta)*cos(gama)*sin(alpha)-cos(alpha)*sin(gama), sin(alpha)*sin(beta);...
%         cos(gama)*sin(alpha)+cos(alpha)*cos(beta)*sin(gama), cos(alpha)*cos(beta)*cos(gama)-sin(alpha)*sin(gama), -cos(alpha)*sin(beta);...
%         sin(beta)*sin(gama), cos(gama)*sin(beta), cos(beta)];
R = Rx*Ry*Rz;
R(:,3)=-R(:,3); %�����R������ԭ�����ֹ������������ϵ
t = [t1, t2, t3]';
T = [R, t];
P = K*T;
P = P/P(3, 4);
xx=(P*X3d')';
xx=xx./repmat(xx(:,3),1,3);
mse=sum(sum((x2d(:,1:2)-xx(:,1:2)).^2))/size(x2d,1);