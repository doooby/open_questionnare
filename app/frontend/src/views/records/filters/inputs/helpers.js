const sizes = ['sm', 'md', 'lg'];

export function sizeClassName (size) {
    if (!size.includes(size)) size = 'md';
    return `-input-${size}`;
}
