-- Permitir acceso anónimo (despliegue sin login)
DROP POLICY IF EXISTS insert_survey        ON surveys;
DROP POLICY IF EXISTS upsert_survey        ON surveys;
DROP POLICY IF EXISTS select_surveys       ON surveys;
DROP POLICY IF EXISTS insert_mobiliario    ON inventario_mobiliario;
DROP POLICY IF EXISTS select_mobiliario    ON inventario_mobiliario;

CREATE POLICY insert_survey     ON surveys               FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY upsert_survey     ON surveys               FOR UPDATE TO anon, authenticated USING (true);
CREATE POLICY select_surveys    ON surveys               FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY insert_mobiliario ON inventario_mobiliario FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY select_mobiliario ON inventario_mobiliario FOR SELECT TO anon, authenticated USING (true);
