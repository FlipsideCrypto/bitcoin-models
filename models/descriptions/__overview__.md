{% docs __overview__ %}

# Bitcoin Models Documentation

This documentation covers the design and structure of the Bitcoin blockchain data models available through Flipside Crypto. These models provide comprehensive access to Bitcoin blockchain data, including blocks, transactions, inputs, outputs, and various analytical views.

## **Quick Links to Table Documentation**

**Click on the links below to jump to the documentation for each schema.**

### CORE Tables

**Dimension Tables:**
- [core__dim_entity_clusters](#!/model/model.bitcoin_models.core__dim_entity_clusters)
- [core__dim_labels](#!/model/model.bitcoin_models.core__dim_labels)

**Fact Tables:**
- [core__fact_blocks](#!/model/model.bitcoin_models.core__fact_blocks)
- [core__fact_clustered_transfers](#!/model/model.bitcoin_models.core__fact_clustered_transfers)
- [core__fact_inputs](#!/model/model.bitcoin_models.core__fact_inputs)
- [core__fact_outputs](#!/model/model.bitcoin_models.core__fact_outputs)
- [core__fact_transactions](#!/model/model.bitcoin_models.core__fact_transactions)

### GOV Tables

**Easy Views:**
- [gov__ez_miner_rewards](#!/model/model.bitcoin_models.gov__ez_miner_rewards)

### PRICE Tables

**Dimension Tables:**
- [price__dim_asset_metadata](#!/model/model.bitcoin_models.price__dim_asset_metadata)

**Fact Tables:**
- [price__fact_prices_ohlc_hourly](#!/model/model.bitcoin_models.price__fact_prices_ohlc_hourly)

**Easy Views:**
- [price__ez_asset_metadata](#!/model/model.bitcoin_models.price__ez_asset_metadata)
- [price__ez_prices_hourly](#!/model/model.bitcoin_models.price__ez_prices_hourly)

### STATS Tables

**Easy Views:**
- [stats__ez_core_metrics_hourly](#!/model/model.bitcoin_models.stats__ez_core_metrics_hourly)

## **Data Model Overview**

The Bitcoin models follow a layered architecture with three main tiers:

- **Bronze Layer**: Raw data ingestion from blockchain sources
- **Silver Layer**: Data cleaning, parsing, and transformation
- **Gold Layer**: Final curated tables and views for analytics

The gold layer is organized into schemas based on domain:
- **CORE**: Fundamental blockchain entities (blocks, transactions, inputs, outputs)
- **GOV**: Governance and mining-related data
- **PRICE**: Asset pricing and metadata
- **STATS**: Aggregated metrics and statistics

Easy views (ez_*) combine multiple fact and dimension tables to simplify common analytical queries.

<llm>
<blockchain>Bitcoin</blockchain>
<aliases>BTC, Bitcoin Core</aliases>
<ecosystem>Layer 1, Proof of Work</ecosystem>
<description>Bitcoin is the first and most widely adopted cryptocurrency, operating as a decentralized peer-to-peer electronic cash system. It uses a proof-of-work consensus mechanism where miners compete to solve cryptographic puzzles to validate transactions and create new blocks. Bitcoin's key features include its fixed supply cap of 21 million coins, transparent blockchain ledger, and resistance to censorship through decentralization. The network processes approximately 7 transactions per second and has a 10-minute average block time, making it suitable for store-of-value use cases and high-value transactions.</description>
<external_resources>
    <block_scanner>https://blockstream.info/</block_scanner>
    <developer_documentation>https://developer.bitcoin.org/</developer_documentation>
</external_resources>
<expert>
  <constraints>
    <table_availability>
      Ensure that your queries use only available tables for Bitcoin. The core schema contains fundamental blockchain data, while specialized schemas (gov, price, stats) provide domain-specific analytics.
    </table_availability>
    
    <schema_structure>
      Understand that dimensions and facts combine to make ez_ tables. Core tables contain the fundamental blockchain entities, while ez_ tables add business logic such as labels, USD price information, and aggregated metrics.
    </schema_structure>
  </constraints>

  <optimization>
    <performance_filters>
      Use filters like block_timestamp over the last N days to improve query speed. Bitcoin data can be large, so always include appropriate time-based filters.
    </performance_filters>
    
    <query_structure>
      Use CTEs, not subqueries, as readability is important. Bitcoin transaction data is complex with inputs and outputs, so clear query structure is essential.
    </query_structure>
    
    <implementation_guidance>
      Be smart with aggregations, window functions, and joins. Bitcoin's UTXO model means transactions can have multiple inputs and outputs, requiring careful handling of value calculations.
    </implementation_guidance>
  </optimization>

  <domain_mapping>
    <token_operations>
      For Bitcoin transfers, use core__fact_clustered_transfers table which handles the UTXO model complexity and provides clean transfer data.
    </token_operations>
    
    <defi_analysis>
      Bitcoin's DeFi ecosystem is primarily focused on Lightning Network and wrapped tokens. Use core__fact_transactions for on-chain activity and specialized tables for Lightning data if available.
    </defi_analysis>
    
    <nft_analysis>
      For Bitcoin NFT analysis (Ordinals, Inscriptions), use the ordinals-specific tables in the silver layer or specialized gold tables if available.
    </nft_analysis>
    
    <specialized_features>
      Bitcoin's UTXO model is complex, so ensure you understand how inputs and outputs relate to transfers. The clustered transfers table simplifies this for most use cases.
    </specialized_features>
  </domain_mapping>

  <interaction_modes>
    <direct_user>
      Ask clarifying questions when dealing with complex Bitcoin data structures, especially around UTXOs, transaction fees, and mining rewards.
    </direct_user>
    
    <agent_invocation>
      When invoked by another AI agent, respond with relevant query text and explain Bitcoin-specific considerations like UTXO model and transaction structure.
    </agent_invocation>
  </interaction_modes>

  <engagement>
    <exploration_tone>
      Have fun exploring the Bitcoin ecosystem through data! Bitcoin's transparent blockchain provides rich insights into economic activity, mining dynamics, and network usage patterns.
    </exploration_tone>
  </engagement>
</expert>
</llm>

{% enddocs %}
