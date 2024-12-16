// ignore_for_file: lines_longer_than_80_chars
// Indexing Settings
const embeddingModelInfoText = 'Select the AI brain that converts your documents into mathematical vectors, capturing their deep semantic meaning. Advanced models offer richer understanding, ideal for complex or diverse content.';
const embeddingModelProtip = 'Use large models for technical or varied content. Smaller models are faster and better suited for simpler texts.';

const embeddingModelContextLengthInfoText = 'Defines the maximum text the AI can process in one session. Longer lengths allow better understanding of complex documents but may require more resources.';
const embeddingModelContextLengthProtip = 'Match the length to your document size. Use longer contexts for research papers and shorter ones for memos or FAQs. Exceeding this limit could truncate the input.';

const embeddingApiUrlInfoText = 'The digital address where your text is processed. This endpoint connects your documents to the AI service for embedding generation.';
const embeddingApiUrlProtip = 'Ensure the URL matches your chosen embedding service’s endpoint exactly.';

const apiKeyInfoText = 'Your unique credential to securely access AI services. Protects your data and ensures only authorized usage.';
const apiKeyProtip = 'Treat it like a password—store it securely and never share it publicly.';

const apiBatchSizeInfoText = 'The number of documents processed simultaneously. Larger batches are faster but use more system resources.';
const apiBatchSizeProtip = 'Adjust batch size based on your system’s memory and processing power. Start small if unsure.';

const databaseBatchSizeInfoText = 'The number of documents stored or retrieved in one operation. Larger batches improve efficiency but may demand more resources.';
const databaseBatchSizeProtip = 'Use smaller batches for limited systems and larger ones for better performance on powerful setups.';

const dimensionsInfoText = 'Defines the complexity of document representation. Higher dimensions create detailed "fingerprints" that capture subtle meanings but require more computation.';
const dimensionsProtip = 'Use higher dimensions for nuanced topics (e.g., legal, medical documents) and lower dimensions for straightforward text.';

const compressedInfoText = 'Reduces vector size while retaining key information. Saves storage space and speeds up processing for large datasets.';
const compressedProtip = 'Enable compression for large collections to optimize storage without sacrificing accuracy.';

// Generation Settings
const generationModelInfoText = 'The AI brain crafting responses based on retrieved documents. Models vary in creativity, precision, and contextual understanding.';
const generationModelProtip = 'Balance quality with efficiency. Creative applications need advanced models, while simpler tasks work well with smaller models.';

const generationApiUrlInfoText = 'The endpoint connecting your application to the AI service that generates responses based on retrieved document segments.';
const generationApiUrlProtip = 'Verify the endpoint matches the service you’re using to avoid connectivity issues.';

const generationApiKeyInfoText = 'A secure token that grants access to the AI generation service. Protects access to sensitive operations.';
const generationApiKeyProtip = 'Store the key securely and rotate it periodically to maintain security.';

const generationContextLengthInfoText = 'Defines how much background information the AI considers when generating responses. Longer contexts provide richer, more comprehensive answers.';
const generationContextLengthProtip = 'Use longer contexts for detailed or complex queries. For simpler responses, shorter contexts suffice.';

const maxTokensInfoText = 'Limits the length of AI-generated responses. Prevents excessively long outputs while ensuring answers are complete.';
const maxTokensProtip = 'Start with half the context length for balanced, informative responses. Adjust based on your use case.';

const temperatureInfoText = 'Controls response creativity. Lower values ensure precise, factual answers; higher values allow for more varied, imaginative outputs.';
const temperatureProtip = '0-0.3: Factual, academic tone. 0.4-0.6: Balanced, conversational tone. 0.7-1.0: Creative, exploratory tone. Combine with Top P for better response control.';

const topPToltip = 'A sampling technique that dynamically selects the most relevant word sequences, providing controlled randomness in responses.';
const topPProtip = 'Use with Temperature for fine-tuned outputs. Lower Top P values prioritize accuracy, while higher values allow more diversity.';

const stopSequenceInfoText = 'Defines when the AI should stop generating responses, helping control structure and length.';
const stopSequenceProtip = 'Use specific domain-related stop words (e.g., “END” or “###”) for structured responses.';

const frequencyPenaltyInfoText = 'Discourages the AI from repeating the same words too often, creating more natural language output.';
const frequencyPenaltyProtip = 'Increase slightly to prevent redundancy in responses, especially for repetitive queries.';

const presencePenaltyInfoText = 'Reduces repetition of entire phrases or ideas, encouraging originality in responses.';
const presencePenaltyProtip = 'Use higher values to ensure diverse, contextually relevant answers without overusing concepts.';

// Splitting Settings
const splittingApiUrlInfoText = 'The endpoint used to send document for splitting into text chunks.';
const splittingApiUrlProtip = 'Ensure the URL points to the correct service handling splitting operations to maintain data integrity.';

const chunkSizeInfoText = 'Determines how large each document segment is when split for analysis. Smaller chunks are easier to process but may reduce context.';
const chunkSizeProtip = 'Adjust based on your document type. Large, dense texts need bigger chunks; lighter content works with smaller ones.';

const chunkOverlapInfoText = 'Ensures continuity between chunks by overlapping segments. Helps retain context across boundaries.';
const chunkOverlapProtip = 'Use a small overlap (e.g., 10-50 characters) to preserve context while avoiding redundant processing.';


// Retrieval Settings
const searchThresholdInfoText = 'Sets a similarity score filter for retrieving documents. Only results meeting the threshold are returned.';
const searchThresholdProtip = 'Use higher thresholds (e.g., 0.8-0.9) for precise matches and lower ones (e.g., 0.5-0.7) for broader searches.';

const topNResultsInfoText = 'Limits the number of most relevant documents retrieved. Balances focused retrieval with comprehensive coverage.';
const topNResultsProtip = 'Use smaller values for focused tasks (e.g., top 3 results) and larger ones for exploratory searches.';
