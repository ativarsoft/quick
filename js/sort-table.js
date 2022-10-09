function sort_table(header){
    var table = $(header).parents('table').eq(0)
    var rows = table.find('tr:gt(0)').toArray().sort(comparer($(header).index()))
    this.asc = !header.asc
    if (!header.asc){rows = rows.reverse()}
    for (var i = 0; i < rows.length; i++){table.append(rows[i])}
}
$('th').click(function(){
    sort_table(this);
});
function comparer(index) {
    return function(a, b) {
        var valA = getCellValue(a, index), valB = getCellValue(b, index)
        return $.isNumeric(valA) && $.isNumeric(valB) ? valA - valB : valA.toString().localeCompare(valB)
    }
}
function getCellValue(row, index){ return $(row).children('td').eq(index).text() }
