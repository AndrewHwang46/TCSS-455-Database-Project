const sql = require('mssql');

async function testConnection() {
    try {
        // Try different connection options
        const configs = [
            {
                name: "Default instance with Windows Auth",
                config: {
                    server: 'localhost',
                    options: { trustServerCertificate: true, trustedConnection: true }
                }
            },
            {
                name: "SQLEXPRESS instance with Windows Auth",
                config: {
                    server: 'localhost\\SQLEXPRESS',
                    options: { trustServerCertificate: true, trustedConnection: true }
                }
            },
            {
                name: "Using integrated security",
                config: {
                    server: 'localhost',
                    options: { trustServerCertificate: true, enableArithAbort: true },
                    integrated: true
                }
            }
        ];

        for (const {name, config} of configs) {
            console.log(`\nTrying connection: ${name}`);
            try {
                const pool = new sql.ConnectionPool(config);
                await pool.connect();
                console.log(`✅ SUCCESS! Connected with: ${name}`);

                // List databases
                const result = await pool.request().query("SELECT name FROM sys.databases");
                console.log("Available databases:");
                result.recordset.forEach(db => console.log(`- ${db.name}`));

                await pool.close();
            } catch (err) {
                console.log(`❌ FAILED: ${err.message}`);
            }
        }
    } catch (err) {
        console.error('Error during tests:', err);
    }
}

testConnection();