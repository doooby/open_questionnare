import raw_locales from './locales.csv';

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

function buildLocalesFromCsv (input_data, languages, remove_headers=true) {
    // remove headers
    if (remove_headers) input_data = input_data.slice(1);

    const root = {};
    languages.forEach(name => root[name] = {});

    input_data.forEach(([key, ...translations]) => {
        if (!key) return;

        const keys = key.split('.');
        const last = keys[keys.length - 1];

        languages.forEach((lang, i) => {
            const value = (translations[i] || '').trim();
            if (value) getParentNode(root[lang], keys)[last] = value;
        });
    });

    return root;
}

const messages = buildLocalesFromCsv(raw_locales, ['en', 'pt']);
export default messages;
