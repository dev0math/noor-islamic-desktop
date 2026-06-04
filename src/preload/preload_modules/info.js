module.exports = async function info(ipcRenderer, shell) {

    let currentRelease = await ipcRenderer.invoke('currentRelease') || "0.0.0";
    document.getElementById("Version").innerHTML = "v" + currentRelease;

    let github = document.getElementById('github');
    let noor = document.getElementById('noor');
    let Developer = document.getElementById('Developer');
    let kader_github = document.getElementById('kader_github');
    let kader_telegram = document.getElementById('kader_telegram');
    let kader_discord = document.getElementById('kader_discord');
    let kader_gmail = document.getElementById('kader_gmail');
    let dependencies = document.getElementById('dependencies');
    let Sources = document.getElementById('Sources');
    let info_li_1 = document.getElementById('info_li_1');
    let info_li_2 = document.getElementById('info_li_2');
    let info_li_3 = document.getElementById('info_li_3');
    let Sources_1 = document.getElementById('Sources_1');
    let Sources_2 = document.getElementById('Sources_2');
    let Sources_3 = document.getElementById('Sources_3');
    let Sources_4 = document.getElementById('Sources_4');
    let Sources_5 = document.getElementById('Sources_5');
    let Sources_6 = document.getElementById('Sources_6');
    let Sources_7 = document.getElementById('Sources_7');
    let Sources_8 = document.getElementById('Sources_8');
    let url_1 = document.getElementById('url_1');
    let url_2 = document.getElementById('url_2');
    let url_3 = document.getElementById('url_3');
    let url_4 = document.getElementById('url_4');
    let url_5 = document.getElementById('url_5');
    let url_6 = document.getElementById('url_6');
    let url_7 = document.getElementById('url_7');
    let url_8 = document.getElementById('url_8');
    let url_9 = document.getElementById('url_9');

    info_li_1.addEventListener('click', e => {
        noor.style.display = 'none'
        Developer.style.display = 'block'
        dependencies.style.display = 'none'
        Sources.style.display = 'none'
    });

    info_li_2.addEventListener('click', e => {
        noor.style.display = 'none'
        Developer.style.display = 'none'
        dependencies.style.display = 'block'
        Sources.style.display = 'none'
    });

    info_li_3.addEventListener('click', e => {
        noor.style.display = 'none'
        Developer.style.display = 'none'
        dependencies.style.display = 'none'
        Sources.style.display = 'table'
    });

    github.addEventListener('click', e => {
        shell.openExternal('https://github.com/dev0math/noor-islamic-desktop')
    });


    kader_github.addEventListener('click', e => {
        shell.openExternal('https://github.com/dev0math')
    });

    kader_telegram.addEventListener('click', e => {
        shell.openExternal('https://t.me/kaderdev')
    });

    kader_discord.addEventListener('click', e => {
        shell.openExternal('https://discord.com/users/dev.math')
    });

    kader_gmail.addEventListener('click', e => {
        shell.openExternal('mailto: kaderdev67@gmail.com')
    });


    Sources_1.addEventListener('click', e => {
        shell.openExternal('https://github.com/dev0math/Quran-Json')
    });

    Sources_2.addEventListener('click', e => {
        shell.openExternal('https://www.mp3quran.net/api/_arabic.json')
    });

    Sources_3.addEventListener('click', e => {
        shell.openExternal('https://www.islambook.com/azkar')
    });

    Sources_4.addEventListener('click', e => {
        shell.openExternal('http://ip-api.com/json')
    });

    Sources_5.addEventListener('click', e => {
        shell.openExternal('https://www.flaticon.com')
    });

    Sources_6.addEventListener('click', e => {
        shell.openExternal('https://fonts.qurancomplex.gov.sa/wp02')
    });

    Sources_7.addEventListener('click', e => {
        shell.openExternal('https://github.com/rastikerdar/vazirmatn')
    });

    Sources_8.addEventListener('click', e => {
        shell.openExternal('https://animate.style/')
    });

    url_1.addEventListener('click', e => {
        shell.openExternal('https://github.com/batoulapps/adhan-js')
    });

    url_2.addEventListener('click', e => {
        shell.openExternal('https://github.com/electron/electron')
    });

    url_3.addEventListener('click', e => {
        shell.openExternal('https://github.com/jprichardson/node-fs-extra')
    });

    url_4.addEventListener('click', e => {
        shell.openExternal('https://momentjs.com/timezone/')
    });

    url_5.addEventListener('click', e => {
        shell.openExternal('https://github.com/node-fetch/node-fetch')
    });

    url_6.addEventListener('click', e => {
        shell.openExternal('https://github.com/maxogden/menubar')
    });

    url_7.addEventListener('click', e => {
        shell.openExternal('https://github.com/zertosh/v8-compile-cache')
    });

    url_8.addEventListener('click', e => {
        shell.openExternal('https://github.com/xsoh/moment-hijri')
    });

    url_9.addEventListener('click', e => {
        shell.openExternal('https://github.com/jsmreese/moment-duration-format')
    });
}
