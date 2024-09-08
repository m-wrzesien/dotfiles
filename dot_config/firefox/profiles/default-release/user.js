// Based mostly on https://github.com/pyllyukko/user.js/blob/master/user.js
// Second source of this is https://github.com/arkenfox/user.js/blob/master/user.js


// Hide warning when entering "about:config"
user_pref("browser.aboutConfig.showWarning", false);


// PREF: Never check updates for search engines
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_auto-update-checking
user_pref("browser.search.update",				false);


// PREF: When geolocation is enabled, use Mozilla geolocation service instead of Google
// https://bugzilla.mozilla.org/show_bug.cgi?id=689252
user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");

// PREF: Don't reveal your internal IP when WebRTC is enabled (Firefox >= 42)
// https://wiki.mozilla.org/Media/WebRTC/Privacy
// https://github.com/beefproject/beef/wiki/Module%3A-Get-Internal-IP-WebRTC
user_pref("media.peerconnection.ice.no_host",			true); // Firefox >= 52

// PREF: When browser pings are enabled, only allow pinging the same host as the origin page
// http://kb.mozillazine.org/Browser.send_pings.require_same_host
user_pref("browser.send_pings.require_same_host",		true);

// PREF: Disable gamepad API to prevent USB device enumeration
// https://www.w3.org/TR/gamepad/
// https://trac.torproject.org/projects/tor/ticket/13023
user_pref("dom.gamepad.enabled",				false);

// PREF: Disable virtual reality devices APIs
// https://developer.mozilla.org/en-US/Firefox/Releases/36#Interfaces.2FAPIs.2FDOM
// https://developer.mozilla.org/en-US/docs/Web/API/WebVR_API
user_pref("dom.vr.enabled",					false);

// PREF: Disable vibrator API
user_pref("dom.vibrator.enabled",           false);


// PREF: Disable GeoIP lookup on your address to set default search engine region
// https://trac.torproject.org/projects/tor/ticket/16254
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_geolocation-for-default-search-engine
user_pref("browser.search.countryCode",				"US");
user_pref("browser.search.region",				"US");
user_pref("browser.search.geoip.url",				"");

// PREF: Set Accept-Language HTTP header to en-US regardless of Firefox localization
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language
user_pref("intl.accept_languages",				"en-US, en");

// PREF: Don't use OS values to determine locale, force using Firefox locale setting
// http://kb.mozillazine.org/Intl.locale.matchOS
user_pref("intl.locale.matchOS",				false);

// PREF: Don't use Mozilla-provided location-specific search engines
user_pref("browser.search.geoSpecificDefaults",			false);

// PREF: Prevent leaking application locale/date format using JavaScript
// https://bugzilla.mozilla.org/show_bug.cgi?id=867501
// https://hg.mozilla.org/mozilla-central/rev/52d635f2b33d
user_pref("javascript.use_us_english_locale",			true);

// PREF: Don't trim HTTP off of URLs in the address bar.
// https://bugzilla.mozilla.org/show_bug.cgi?id=665580
user_pref("browser.urlbar.trimURLs",				false);


// PREF: Disable Mozilla telemetry/experiments
// https://wiki.mozilla.org/Platform/Features/Telemetry
// https://wiki.mozilla.org/Privacy/Reviews/Telemetry
// https://wiki.mozilla.org/Telemetry
// https://www.mozilla.org/en-US/legal/privacy/firefox.html#telemetry
// https://support.mozilla.org/t5/Firefox-crashes/Mozilla-Crash-Reporter/ta-p/1715
// https://wiki.mozilla.org/Security/Reviews/Firefox6/ReviewNotes/telemetry
// https://gecko.readthedocs.io/en/latest/browser/experiments/experiments/manifest.html
// https://wiki.mozilla.org/Telemetry/Experiments
// https://support.mozilla.org/en-US/questions/1197144
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/preferences.html#id1
user_pref("toolkit.telemetry.enabled",				false);
user_pref("toolkit.telemetry.unified",				false);
user_pref("toolkit.telemetry.archive.enabled",			false);
user_pref("experiments.supported",				false);
user_pref("experiments.enabled",				false);
user_pref("experiments.manifest.uri",				"");

// PREF: Disallow Necko to do A/B testing
// https://trac.torproject.org/projects/tor/ticket/13170
user_pref("network.allow-experiments",				false);

// PREF: Disable FlyWeb (discovery of LAN/proximity IoT devices that expose a Web interface)
// https://wiki.mozilla.org/FlyWeb
// https://wiki.mozilla.org/FlyWeb/Security_scenarios
// https://docs.google.com/document/d/1eqLb6cGjDL9XooSYEEo7mE-zKQ-o-AuDTcEyNhfBMBM/edit
// http://www.ghacks.net/2016/07/26/firefox-flyweb
user_pref("dom.flyweb.enabled",		            false);

// PREF: Enable contextual identity Containers feature (Firefox >= 52)
// NOTICE: Containers are not available in Private Browsing mode
// https://wiki.mozilla.org/Security/Contextual_Identity_Project/Containers
user_pref("privacy.userContext.enabled",			true);

// PREF: disable mozAddonManager Web API [FF57+]
// https://bugzilla.mozilla.org/buglist.cgi?bug_id=1384330
// https://bugzilla.mozilla.org/buglist.cgi?bug_id=1406795
// https://bugzilla.mozilla.org/buglist.cgi?bug_id=1415644
// https://bugzilla.mozilla.org/buglist.cgi?bug_id=1453988
// https://trac.torproject.org/projects/tor/ticket/26114
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);
user_pref("extensions.webextensions.restrictedDomains", "");

// PREF: Disable Shield/Heartbeat/Normandy (Mozilla user rating telemetry)
// https://wiki.mozilla.org/Advocacy/heartbeat
// https://trac.torproject.org/projects/tor/ticket/19047
// https://trac.torproject.org/projects/tor/ticket/18738
// https://wiki.mozilla.org/Firefox/Shield
// https://github.com/mozilla/normandy
// https://support.mozilla.org/en-US/kb/shield
// https://bugzilla.mozilla.org/show_bug.cgi?id=1370801
// https://wiki.mozilla.org/Firefox/Normandy/PreferenceRollout
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("extensions.shield-recipe-client.enabled",		false);
user_pref("app.shield.optoutstudies.enabled",			false);

// PREF: Disable Pocket
// https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
// https://github.com/pyllyukko/user.js/issues/143
user_pref("browser.pocket.enabled",				false);
user_pref("extensions.pocket.enabled",				false);

// PREF: Disable "Recommended by Pocket" in Firefox Quantum
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories",	false);

// PREF: Disable password manager (use an external password manager!)
// CIS Version 1.2.0 October 21st, 2011 2.5.2
user_pref("signon.rememberSignons",				false);

// PREF: Disable Mozilla VPN ads on the about:protections page
// https://support.mozilla.org/en-US/kb/what-mozilla-vpn-and-how-does-it-work
// https://en.wikipedia.org/wiki/Mozilla_VPN
// https://blog.mozilla.org/security/2021/08/31/mozilla-vpn-security-audit/
// https://www.mozilla.org/en-US/security/advisories/mfsa2021-31/
user_pref("browser.vpn_promo.enabled",			false);

// PREF: Disable sponsored in top sites
user_pref("browser.newtabpage.activity-stream.showSponsored",	false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites",	false);
user_pref("browser.newtabpage.activity-stream.topSiteSearchShortcuts", false);

// Enable DRM by default
user_pref("media.eme.enabled", true);

// Place dev tools on the right
user_pref("devtools.toolbox.host", "right");

// By default open "Network" tab in dev tools
user_pref("devtools.toolbox.selectedTool", "netmonitor");

// Always display bookmark toolbar - currently doesn't work - https://bugzilla.mozilla.org/show_bug.cgi?id=1808097
user_pref("browser.toolbars.bookmarks.visibility", "always");

// Disable welcome screen
user_pref("trailhead.firstrun.branches", "nofirstrun-empty");
user_pref("browser.aboutwelcome.enabled", false);

// Set Toolbar style - can be fetched from `prefs.js` in profile directory
user_pref("browser.uiCustomization.state", "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"_testpilot-containers-browser-action\",\"canvasblocker_kkapsner_de-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"unified-extensions-button\",\"ublock0_raymondhill_net-browser-action\",\"browser-extension_anonaddy-browser-action\",\"cookieautodelete_kennydo_com-browser-action\",\"addon_darkreader_org-browser-action\",\"jid0-oewf5zcskghjfv4kk4lyc_jetpack-browser-action\",\"_c3c10168-4186-445c-9c5b-63f12b8e2c87_-browser-action\",\"_62c00091-53f5-42d0-a4d0-9e69fc3d5819_-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"import-button\",\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"browser-extension_anonaddy-browser-action\",\"canvasblocker_kkapsner_de-browser-action\",\"cookieautodelete_kennydo_com-browser-action\",\"addon_darkreader_org-browser-action\",\"jid0-oewf5zcskghjfv4kk4lyc_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_c3c10168-4186-445c-9c5b-63f12b8e2c87_-browser-action\",\"_62c00091-53f5-42d0-a4d0-9e69fc3d5819_-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"PersonalToolbar\",\"unified-extensions-area\",\"toolbar-menubar\",\"TabsToolbar\"],\"currentVersion\":19,\"newElementCount\":4}");

// Disable translation for one of the languages
user_pref("browser.translations.neverTranslateLanguages", "pl");

/*** [SECTION 2800]: SHUTDOWN & SANITIZING ***/
user_pref("_user.js.parrot", "2800 syntax error: the parrot's bleedin' demised!");
/* 2810: enable Firefox to clear items on shutdown
 * [SETTING] Privacy & Security>History>Custom Settings>Clear history when Firefox closes | Settings ***/
user_pref("privacy.sanitize.sanitizeOnShutdown", true);

/** SANITIZE ON SHUTDOWN: IGNORES "ALLOW" SITE EXCEPTIONS ***/
/* 2811: set/enforce what items to clear on shutdown (if 2810 is true) [SETUP-CHROME]
 * [NOTE] If "history" is true, downloads will also be cleared
 * [NOTE] "sessions": Active Logins: refers to HTTP Basic Authentication [1], not logins via cookies
 * [1] https://en.wikipedia.org/wiki/Basic_access_authentication ***/
user_pref("privacy.clearOnShutdown.cache", true);     // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.downloads", false); // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.formdata", false);  // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.history", false);   // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.sessions", true);  // [DEFAULT: true]
   // user_pref("privacy.clearOnShutdown.siteSettings", false); // [DEFAULT: false]
/* 2812: set Session Restore to clear on shutdown (if 2810 is true) [FF34+]
 * [NOTE] Not needed if Session Restore is not used (0102) or it is already cleared with history (2811)
 * [NOTE] If true, this prevents resuming from crashes (also see 5008) ***/
user_pref("privacy.clearOnShutdown.openWindows", false);

/** SANITIZE ON SHUTDOWN: RESPECTS "ALLOW" SITE EXCEPTIONS FF103+ ***/
/* 2815: set "Cookies" and "Site Data" to clear on shutdown (if 2810 is true) [SETUP-CHROME]
 * [NOTE] Exceptions: A "cookie" block permission also controls "offlineApps" (see note below).
 * serviceWorkers require an "Allow" permission. For cross-domain logins, add exceptions for
 * both sites e.g. https://www.youtube.com (site) + https://accounts.google.com (single sign on)
 * [NOTE] "offlineApps": Offline Website Data: localStorage, service worker cache, QuotaManager (IndexedDB, asm-cache)
 * [WARNING] Be selective with what sites you "Allow", as they also disable partitioning (1767271)
 * [SETTING] to add site exceptions: Ctrl+I>Permissions>Cookies>Allow (when on the website in question)
 * [SETTING] to manage site exceptions: Options>Privacy & Security>Permissions>Settings ***/
user_pref("privacy.clearOnShutdown.cookies", true); // Cookies
user_pref("privacy.clearOnShutdown.offlineApps", true); // Site Data

// Disable DNS over HTTPS, as we have our own internal dns
user_pref("network.trr.mode", 5);

// https://make-firefox-private-again.com/
// https://blog.mozilla.org/en/mozilla/privacy-preserving-attribution-for-advertising/
// Disable mozilla advertising
user_pref("dom.private-attribution.submission.enabled", false);

// Disable info about weather in new tab, as it is based on AccuWeather
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.system.showWeather", false);