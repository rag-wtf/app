// ignore_for_file: lines_longer_than_80_chars

const enabledAnalyticsInfoText = 'Enabled anonymous reporting of crash and event data';

// Indexing Settings
const embeddingModelInfoText = 'Select the embedding model that converts your documents into mathematical vectors, capturing their deep semantic meaning. Advanced models offer richer understanding, ideal for complex or diverse content.';
const embeddingModelContextLengthInfoText = 'Defines the maximum text the model can process in one session. Longer lengths allow better understanding of complex documents but may require more resources. Exceeding this limit could truncate the input.';
const embeddingApiUrlInfoText = 'The address where your text is processed. This endpoint connects your documents to the AI service for embedding generation.';
const embeddingApiKeyInfoText = 'Your unique credential to access the embedding services.\nTreat it like a password—store it securely and ensures only authorized usage.';
const embeddingApiBatchSizeInfoText = 'The number of documents processed simultaneously. Larger batches are faster but use more system resources.';
const databaseBatchSizeInfoText = 'The number of documents stored in one operation. Larger batches improve efficiency but may demand more resources.';
const dimensionsInfoText = 'Defines the complexity of document representation. Higher dimensions create detailed "fingerprints" that capture subtle meanings but require more computation and storage.';
const compressedInfoText = 'Specifies whether requests and responses are compressed using gzip, optimizing bandwidth usage and improving transmission efficiency for large data exchanges.';

// Generation Settings
const generationModelInfoText = 'Select the generative model that crafting responses based on retrieved documents. Models vary in creativity, precision, and contextual understanding.';
const generationApiUrlInfoText = 'The endpoint connecting your application to the AI service that generates responses based on retrieved document segments.';
const generationApiKeyInfoText = 'Your unique credential that grants access to the generative AI service. Store it securely and never share it publicly.';
const generationContextLengthInfoText = 'Defines how much background information the AI considers when generating responses. Longer contexts provide richer, more comprehensive answers.';
const maxTokensInfoText = 'Limits the length of AI-generated responses. Prevents excessively long outputs while ensuring answers are complete.';
const temperatureInfoText = 'Controls response creativity. Lower values ensure precise, factual answers; higher values allow for more varied, imaginative outputs.\n0-0.3: Factual, academic tone.\n0.4-0.6: Balanced, conversational tone.\n0.7-1.0: Creative, exploratory tone.';
const topPInfoText = 'A sampling technique that dynamically selects the most relevant word sequences, providing controlled randomness in responses.';

const stopSequenceInfoText = 'Defines when the AI should stop generating responses, helping control structure and length.';
const stopSequenceProtip = 'Use specific domain-related stop words (e.g., “END” or “###”) for structured responses.';

const frequencyPenaltyInfoText = 'Increase slightly to discourage the AI from repeating the same words too often, creating more natural language output.';
const presencePenaltyInfoText = 'Reduces repetition of entire phrases or ideas, encouraging originality in responses.';
const enabledStreamingInfoText = 'Indicates whether the AI responses are sent incrementally as they are generated, reducing wait times for long outputs.';

// Splitting Settings
const splittingApiUrlInfoText = 'The endpoint that connects to the text-splitting service, which divides your document into manageable chunks for efficient processing.';
const chunkSizeInfoText = 'Determines how large each document segment is when split for indexing. Smaller chunks are easier to process but may reduce context.';
const chunkOverlapInfoText = 'Ensures continuity between chunks by overlapping segments. Helps retain context across boundaries.';


// Retrieval Settings
const searchThresholdInfoText = 'Sets a similarity score filter for retrieving documents. Only results meeting the threshold and above are returned.';
const topNResultsInfoText = 'Limits the number of most relevant documents retrieved. Balances focused retrieval with comprehensive coverage.';
