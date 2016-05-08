
% disable JxBrowser to prevent idle cpu use
com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLRENDERER');

addpath(genpath(pwd));
rmpath(genpath([pwd,'/drake-distro/drake/examples/']));
rmpath([pwd,'/lib/ellipsoids/solvers/SeDuMi_1_1']);
rmpath([pwd,'/lib/mpt/solvers/SeDuMi_1_3']);
addpath(genpath('/home/jon/Software/mosek'));

run([pwd,'/drake-distro/drake/addpath_drake']);

examplesPath = [pwd,'/examples'];
