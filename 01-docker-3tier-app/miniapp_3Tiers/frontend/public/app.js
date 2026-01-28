async function checkHealth() {
    try {
        const response = await fetch('/api/health');
        const data = await response.json();
        
        // Afficher dans le div #result
        document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
    } catch (error) {
        document.getElementById('result').innerHTML = 'Error: ' + error.message;
    }
}

async function addVisit() {
    try {
        const response = await fetch('/api/visit');
        const data = await response.json();
        
        // Afficher dans le div #result
        document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
    } catch (error) {
        document.getElementById('result').innerHTML = 'Error: ' + error.message;
    }
}

async function initDB() {
    try {
        const response = await fetch('/api/init-db');
        const data = await response.json();
        
        // Afficher dans le div #result
        document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
    } catch (error) {
         document.getElementById('result').innerHTML = 'Error: ' + error.message;
    }
}  
