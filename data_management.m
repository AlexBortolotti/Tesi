% csv_url = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv";
% websave('region.csv',csv_url);

LOMBARDIA = 3;
EMILIA = 8;

REGIONE = LOMBARDIA;

region_data = readtable('region.csv');

columns = {'data', 'totale_positivi', 'dimessi_guariti', 'deceduti', 'tamponi', 'totale_casi'};
data = {};
[totale_positivi, dimessi_guariti, deceduti, tamponi, totale_casi] = deal([]);
data_table = table(data, totale_positivi, dimessi_guariti, deceduti, tamponi, totale_casi);

for row = 1:height(region_data)
    codice_regione = table2array(region_data(row,3));
    if codice_regione == REGIONE
        data_table = [data_table; region_data(row,columns)];
    end
end

clear codice_regione data cdv_url deceduti dimessi_guariti tamponi totale_casi totale_positivi