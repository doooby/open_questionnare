
export const ranges = {
    5: [ 4.5, 5    ],
    4: [ 3.5, 4.49 ],
    3: [ 2.5, 3.49 ],
    2: [ 1.5, 2.49 ],
    1: [ 1  , 1.49 ]
};

export function grade (value) {
    return Math.floor(value + .5);
}

export function isBad (value) {
    const val_grade = grade(value);
    if (val_grade < 3) return colors[val_grade];
}

export const colors = {
    5: '#5CBE27',
    4: '#B5E45C',
    3: '#fff321',
    2: '#ffbf3f',
    1: '#ff3d3d',
};

export function color (value) {
    return colors[grade(value)];
}

export const texts = {
    1: 'mau',
    2: 'médiocre',
    3: 'suficiente',
    4: 'bom',
    5: 'muito bom',
};

export const grades = [ 1, 2, 3, 4, 5 ];
