/*! coi-serviceworker v0.1.7 - Guido Zuidhof and contributors, licensed under MIT */
let coepCredentialless = false;
if (typeof window === 'undefined') {
    self.addEventListener("install", () => self.skipWaiting());
    self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));

    self.addEventListener("message", (ev) => {
        if (!ev.data) {
            return;
        } else if (ev.data.type === "deregister") {
            self.registration
                .unregister()
                .then(() => {
                    return self.clients.matchAll();
                })
                .then(clients => {
                    clients.forEach((client) => client.navigate(client.url));
                });
        } else if (ev.data.type === "coepCredentialless") {
            coepCredentialless = ev.data.value;
        }
    });

    self.addEventListener("fetch", function (event) {
        const r = event.request;
        if (r.cache === "only-if-cached" && r.mode !== "same-origin") {
            return;
        }

        const request = (coepCredentialless && r.mode === "no-cors")
            ? new Request(r, {
                credentials: "omit",
            })
            : r;
        event.respondWith(
            fetch(request)
                .then((response) => {
                    if (response.status === 0) {
                        return response;
                    }

                    const newHeaders = new Headers(response.headers);
                    newHeaders.set("Cross-Origin-Embedder-Policy",
                        coepCredentialless ? "credentialless" : "require-corp"
                    );
                    if (!coepCredentialless) {
                        newHeaders.set("Cross-Origin-Resource-Policy", "cross-origin");
                    }
                    newHeaders.set("Cross-Origin-Opener-Policy", "same-origin");

                    return new Response(response.body, {
                        status: response.status,
                        statusText: response.statusText,
                        headers: newHeaders,
                    });
                })
                .catch((e) => console.error(e))
        );
    });

} else {
    (() => {
        const reloadedBySelf = window.sessionStorage.getItem("coiReloadedBySelf");
        window.sessionStorage.removeItem("coiReloadedBySelf");
        const coepDegrading = (reloadedBySelf == "coepdegrade");

        const coepCredentialless = !coepDegrading && (typeof window.credentialless !== "undefined");
        const registerAndReload = (shouldReload) => {
            navigator.serviceWorker
                .register("./coi-serviceworker.js", {
                    scope: window.location.pathname.replace(/[^\/]+$/, ""),
                })
                .then((registration) => {
                    registration.active?.postMessage({
                        type: "coepCredentialless",
                        value: coepCredentialless,
                    });
                    if (shouldReload) {
                        window.sessionStorage.setItem("coiReloadedBySelf", coepDegrading ? "coepdegrade" : "");
                        window.location.reload();
                    }
                });
        };

        if (navigator.serviceWorker) {
            navigator.serviceWorker.getRegistration().then((registration) => {
                if (registration?.active?.scriptURL.endsWith("/coi-serviceworker.js")) {
                    return;
                }
                registerAndReload(!coepDegrading);
            });
        }

        if (!window.crossOriginIsolated && !coepDegrading) {
            window.addEventListener("load", () => {
                if (!window.crossOriginIsolated) {
                    registerAndReload(true);
                }
            });
        }
    })();
}
