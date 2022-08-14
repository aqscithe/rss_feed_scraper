use chrono::{Utc, DateTime, Duration};
use discord_news_bot::{WEBHOOK_URL, RUN_FREQUENCY, RSS_FEEDS};
use reqwest::Client;
use serde_json::{json, Value};
use xmltojson::{to_json};
use std::{error::Error};


#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // init request client
    let client = Client::new();

    for feed in &RSS_FEEDS {
        // GET request to rss feed
        let get_resp = client.get(*feed)
        .send()
        .await?
        .text()
        .await?;

        // convert text response to json
        let items = text_to_json(&get_resp);

        // loop over items in rss feed
        for idx in 0..items.as_array().unwrap().len() {
            // grab current datetime
            let time_now = Utc::now();
            time_now.to_rfc2822();

            // grab datetime of published article
            let mut pub_date_slice: &str = &items[idx]["pubDate"].to_string();
            pub_date_slice = pub_date_slice.trim_matches('\"');
            
            // ensure time is in proper format
            let result = DateTime::parse_from_rfc2822(pub_date_slice);
            let pub_date = match result {
                Ok(_o) => result.unwrap(),
                Err(ref _e) => result.expect("Error parsing rfc2822 pub_date string"),
            }; 
            
            // Check if article was published since the last time the script was ran
            if time_now.signed_duration_since(pub_date) <= Duration::seconds(RUN_FREQUENCY as i64) {
                // prep body for POST request
                let post_body = json!({
                    "username": "CryptoBot",
                    "content": format!("{}\n{}", items[idx]["title"], items[idx]["link"])
                });

                // POST request to webhook
                client.post(WEBHOOK_URL)
                    .header("Content-Type", "application/json")
                    .body(post_body.to_string())
                    .send()
                    .await?;
            }
        }
    }

    Ok(())

}

fn text_to_json(s: &str) -> Value {
    let result = to_json(s);
    let body = match result {
        Ok(_) => result.unwrap(),
        Err(ref _e) => result.expect("Error on GET request"),
    };
    json!(body["rss"]["channel"]["item"])
}