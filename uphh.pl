#!/opt/bin/perl -w

use strict;
use warnings;
use Encode;
use LWP::Debug qw(+);
use WWW::Mechanize;
use HTTP::Cookies;
use Logger::Syslog;

logger_init();
logger_prefix("UP resume on www.hh.ru");

my $URL         = "http://www.hh.ru";
my $mech        = WWW::Mechanize->new();
my $username    = 'username';
my $password    = 'password';
my @resumes     = ('Инженер - программист', 'Аналитик / технолог банковских процессов и технологий', 'Программист / разработчик на c / c++ (c / c++)', 'Программист / разработчик на perl', 'Руководящая должность в ИТ подразделении компании');

eval
{
    $mech->agent_alias('Windows IE 6');
    $mech->cookie_jar(HTTP::Cookies->new(file => 'uphh.cookies', autosave => 1));
    $mech->add_header('Accept-Charset'  => 'windows-1251');
    $mech->add_header('Accept-Encoding' => 'identity');

    info("get url: $URL");

    $mech->get($URL);

    if (defined($mech->form_with_fields("username",  "password", "remember", "action")))
    {
        info("login\n");
    
        $mech->field("username", $username);
        $mech->field("password", $password);
        $mech->field("remember", 'on');
        $mech->click("action");
    }

    info("follow link: Мои резюме\n");

    $mech->follow_link(text => decode('cp1251',"Мои резюме"));

    foreach my $resume (@resumes)
    {
        info("open resume: $resume");
        $mech->follow_link(text => decode('cp1251', $resume));
        info("follow link: редактировать");
        $mech->follow_link(text => decode('cp1251', "редактировать"));
        $mech->form_with_fields("wizardMode",  "resumeId", "stepNumber", "language");
        info("save resume: $resume");
        $mech->click("saveAction.x");    
    }

};

error($@) if ($@);

info("finish");

logger_close();

exit (0);




