
function getParentNode (root, keys) {
    let parent = root, child, i = 0, last = keys.length - 1, key;

    for (; i<last; i+=1) {
        key = keys[i];
        child = parent[key];
        if (!child) {
            child = {};
            parent[key] = child;
        }
        parent = child;
    }
    return parent;
}

export function buildLocales (input_data, languages) {
    const root = {};
    languages.forEach(name => root[name] = {});

    input_data.forEach(([key, ...translations]) => {
        if (!key || key.substr(0,1) === '#') return;

        const keys = key.split('.').map(k => k.trim());
        const last = keys[keys.length - 1];

        languages.forEach((lang, i) => {
            const value = (translations[i] || '').trim();
            if (value) getParentNode(root[lang], keys)[last] = value;
        });
    });

    return root;
}
