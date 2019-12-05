
export function createTextMatcher (to_match) {
    to_match = to_match.toLowerCase();
    return function (text) {
        return text.toLowerCase().indexOf(to_match) !== -1;
    };
}

export function sanitizeCsvCell (row, index) {
    const raw = row[index];
    return raw ? raw.trim() : null;
}

export function sanitizeCsvRow (row, length) {
    const sanitized = [];
    for (let i=0; i<length; i+=1) {
        sanitized[i] = sanitizeCsvCell(row, i);
    }
    return sanitized;
}

export function isObject (o) {
    return o !== null && typeof o === 'object';
}
