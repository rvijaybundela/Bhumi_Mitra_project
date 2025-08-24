'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "7d533d0b19ad22c31c260638f7655bc0",
".git/config": "920a11de313bfb8d93d81f4a3a5b71b6",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "d41d8cd98f00b204e9800998ecf8427e",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "4a6f625f793fa13d1f73afcc32a3806f",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "81826d52d4085f78fe790acf9d581d9b",
".git/logs/refs/heads/main": "81826d52d4085f78fe790acf9d581d9b",
".git/objects/02/6a39f86b198460e2e355df1b7ea791820cd6fe": "a13065f81c69fdaec9112cc09833edd5",
".git/objects/07/a06df0d1d39cbad6ee49a80be09b2919f26551": "9fb5135f4c8b5cee4f85ca9a91a05f44",
".git/objects/16/51f72519a834992af77b4ccf0698e62acfe638": "af954ff7ac034b5e9c64e47b955adce1",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/2b/2b588966bf6ec615084828bf9f25c3aa1c3d6c": "d0f4b4c210f347372d1df74a49135cc1",
".git/objects/2c/ed5137979b8de23c88993c62a8810b86aad569": "a2094b72e86eb1941d999dd4dbc41d92",
".git/objects/39/6f9eaf62132716b4436da4f596bad21d9d197c": "227607ea274f2b3b9783269eb2e63d2e",
".git/objects/3a/ea2b77ae2d3112290d80bda03bb35a25ffffbc": "a05b776b0ebf57df3b1f807aae8d549b",
".git/objects/3c/fabb04989b86a02ca6f4c7fb50e8340a347e2a": "cc5d6df6edbadb264bb6aad4b8fdc687",
".git/objects/3f/dde8a56155767f3409aad4ceb12c93b5c2002a": "62c9a0a3d1bd54c21a175011a7066517",
".git/objects/40/e5c0efbb6b31cf203163c7206d51028e011071": "40e0523724d0375beb7210e0d4e8fd51",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/48/b24c834c6a4af359768c30b0f7ad54b01a7bd1": "a178f009d32f47a80f8a4f4a6d60e8e8",
".git/objects/49/ddbf33112e55e444f0ff45469461448741f1b1": "3eddb1ff892b2a362fdb5f17527382c8",
".git/objects/53/925c5daead855e1c51f2c28c9e24ef1beea45e": "a9ec7c6bf5b7ecf82b4a8bc04426cd2a",
".git/objects/61/5363ed25afe2d792c3dc6dd94eaa6aa3e9e2a9": "e470963bfa47a2989eb41bff45a5790f",
".git/objects/6a/cc7877227957ecd3398e5776a836bc0c636969": "91080b561af43d4d3b5b64875b02e389",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/70/cf8254ec65795e5f609a6ed94f26019a7c8ec8": "654bbdd59406507e370a807fd5bf9eb3",
".git/objects/73/e7de17908b367f83fd14a3bf434c3e099e1b60": "bfc54fa1e836849ddbbdd82a908b7a77",
".git/objects/77/0daea1813a9dbf7ed5a30870e80547221213af": "e5d2a82d4b0db34b4a5a7529a93f2f3a",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/7b/1de67f10e1b3c19ce6bf3aad27aaad7c1ad054": "7df6f2f6dd286be7486d773a128c6035",
".git/objects/7e/28b4021433fe95c470c40c69fc21efe7025645": "3e94e998d926f706e35c07e0b2069d7e",
".git/objects/83/9023e6e75da18b56d9a3fa3a7237497582cb15": "9daa817c82fd8865334b8bfc11c87fc2",
".git/objects/83/d8a8793df1d3ff29dd3fc883c17f93dc8edddc": "5c83dc3ec18f314f4833616c1d5089c7",
".git/objects/88/63734fbbaacf4dc5506cbfcd8b0219063cc9bf": "02d9fc2aca5a1c86bc0d2b34da9f05b6",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8b/10a1578f991ec766f283dbccbe4c5492adb341": "dc5e95c09819208c2ce40843069a112e",
".git/objects/95/6b5949f1b6ed310bf083b75554dbedb2c806d6": "7d221884e53dfee7f9541dda777dbdaf",
".git/objects/95/94911cae4560a1bd6aec9f5d2eb774a84f8d67": "b996c5b8317bd506cd31b8a9f8eaaf21",
".git/objects/95/95ef3ca766733bfd5514f463f1a5d2a5bfe632": "09465cb34e3911e9f7a52ad4e749a929",
".git/objects/9e/da8b4316128c93b23949579e6d8e216616b235": "343891990bb9931a10e4a12d3a3adf88",
".git/objects/a3/611527e52b72e4f58b979a2c2e187babb44439": "05f2e94fdd1511cbfae0c87cb7037043",
".git/objects/a4/41184d5309f128b40764a3f621e777b4d9267f": "18396ec53fb5971a544c2c017fd0d744",
".git/objects/a9/e247bd7fdecaa0e5f4cec7d376867d93f3cdba": "cfc677fe8f8ca3c6d2d33613222b562c",
".git/objects/ac/697abf195c6688abfeaf9617f51b0dc3bf9499": "7eaba39017861bc7525707486ef5c330",
".git/objects/b1/7c96718997d717da4eaa5352c995125270d30b": "c6af4996bfde0ac52ba4b830fcb284f1",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/bd/f8151ccd249ca09c97cd2b6e420628537d8492": "58a526d2e1014e6ed20c174518871851",
".git/objects/c8/214ad0da8960ccb732865ea0bd8009da3b5cd4": "87f42e42e4a03e26f3fa34fb69668f9c",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/d1/e56237066ba1c8c938864e4a89231658d0dc4b": "6c60bca94b2535cd956a959f71bcbdb0",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d9/efbd6161786d03474c68e7a7b2478ba0d75048": "01d2938c67928131e3ee7ab06f10c783",
".git/objects/e2/66978e0a067e8dc542978f905b46629f5c8833": "6eb2f67b9dbce2d64ffbd70e8f78b1aa",
".git/objects/e3/f2c664d4d996bb070d417c1b1414dff7e3bb02": "1dc04b3132df47b9c61162ca20188464",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/211cab1bcd89097b86f6ed8fbd617d43f78773": "410d17db43bbc9597a7491bdad50c959",
".git/objects/ec/2c84505ff37279251c48d6b1a3e722721a1ac4": "516eb2efc964d12ffd3f13309420e6d6",
".git/objects/f0/5e8bb7b9fac41ce69106b621dc66f237008f52": "43206fc144623ec3e863a92a6c09d007",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f5/83adb00bcc9b3dfd27a1d658dd021ea137eaea": "9b6234ed83c37857d7443ff18d52a231",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/refs/heads/main": "5dc7fcc8953577f2d1144b518647b445",
"assets/AssetManifest.bin": "33903b00479542fb88fdc94830716d74",
"assets/AssetManifest.bin.json": "5e79a4b53503b05b763d35a326a6af1f",
"assets/assets/data/panvel_villages.geojson": "52046a6bb81dd79ae48c77a61fe6255f",
"assets/assets/data/village.json": "7e3f2313af0aa21e0929d75d11b342d8",
"assets/assets/images/app_icon.png.placeholder": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/images/bg_map.png": "61c64cc988d7847628c92f5d6c4fc0f5",
"assets/assets/images/emblem_india.png": "9a1e3a72d15b0272b583d408d7846733",
"assets/assets/images/government_emblem_placeholder.txt": "cf6571d44fc7f8ea08392c283c062336",
"assets/assets/images/government_logo.png.placeholder": "36e3593fe8086bfc89c39d8ffa287754",
"assets/assets/images/splash_bg.png.placeholder": "d41d8cd98f00b204e9800998ecf8427e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e5fb7eec597f18c8f7d0eee8350ce81f",
"assets/NOTICES": "5f378dde37075e0a4bd57b1accd6a17b",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "0f738d891bb1f23f4c92a53b1dbe9923",
"canvaskit/canvaskit.wasm": "f2713f2b670aae4db5943cbd230d5871",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "25f3c8d8caeee631dd74268333054938",
"canvaskit/chromium/canvaskit.wasm": "f55fe578aed5b0eedff21b248adeb8db",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "3585a96f8602d8ba5f6da114f370ef4b",
"canvaskit/skwasm.wasm": "e640efab41cf9d28aaa4d402ab890722",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "2b83754a9bf40538ead5c75d7c3941b9",
"canvaskit/skwasm_heavy.wasm": "eb9c6891ffa75136bbb6b45f02978548",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "ae24e980acc66c89f085fcbbce491f6d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6ad0e33862258068486404b13567e659",
"/": "6ad0e33862258068486404b13567e659",
"main.dart.js": "b598784b96af8fcf6c29af53babf80ed",
"manifest.json": "7bc7a3ad38278b701ca7e1f2127fe3f3",
"README.md": "a6b090db5262e370adf8c0fce109f914",
"version.json": "c2e68329ae223de74bbb5a382597d9ad"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
