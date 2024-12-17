// ignore_for_file: lines_longer_than_80_chars

const enabledAnalyticsInfoText = 'Enables anonymous reporting of crash and event data.';

// Indexing Settings
const embeddingModelInfoText = 'Select the embedding model that converts your documents into mathematical vectors, capturing their deep semantic meaning. Advanced models provide richer understanding, ideal for complex or diverse content.';
const embeddingModelContextLengthInfoText = 'Defines the maximum text length the model can process in a single session. Longer lengths enhance understanding of complex documents but may require more resources. Exceeding this limit may truncate the input.';
const embeddingApiUrlInfoText = 'The endpoint where your text is processed. This connects your documents to the AI service for embedding generation.';
const embeddingApiKeyInfoText = 'Your unique credential for accessing embedding services. Treat it like a password—store it securely to ensure only authorized usage.';
const embeddingApiBatchSizeInfoText = 'Specifies the number of documents processed simultaneously. Larger batches process faster but require more system resources.';
const databaseBatchSizeInfoText = 'Specifies the number of documents stored in one operation. Larger batches improve efficiency but may demand more resources.';
const dimensionsInfoText = 'Defines the complexity of document representation. Higher dimensions create more detailed "fingerprints" that capture subtle meanings but require additional computation and storage.';
const compressedInfoText = 'Indicates whether requests and responses are compressed using gzip, reducing bandwidth consumption and improving transmission efficiency for large data exchanges.';

// Generation Settings
const generationModelInfoText = 'Select the generative model that crafts responses based on retrieved documents. Models vary in creativity, precision, and contextual understanding.';
const generationApiUrlInfoText = 'The endpoint that connects your application to the AI service for generating responses based on retrieved document segments.';
const generationApiKeyInfoText = 'Your unique credential for accessing the generative AI service. Store it securely and never share it publicly.';
const generationContextLengthInfoText = 'Specifies how much background information the AI considers when generating responses. Longer contexts enable richer, more comprehensive answers.';
const maxTokensInfoText = 'Sets a limit on the length of AI-generated responses, preventing excessively long outputs while ensuring completeness.';
const temperatureInfoText = 'Controls response creativity. Lower values ensure precise, factual answers, while higher values allow for more varied and imaginative outputs.\n0-0.3: Factual, academic tone.\n0.4-0.6: Balanced, conversational tone.\n0.7-1.0: Creative, exploratory tone.';
const topPInfoText = 'A sampling technique that dynamically selects the most relevant word sequences, balancing accuracy and randomness in responses.';
const stopSequenceInfoText = 'Defines when the AI should stop generating responses, helping control output structure and length.';
const frequencyPenaltyInfoText = 'Discourages the AI from repeating the same words excessively, creating more natural and varied language.';
const presencePenaltyInfoText = 'Reduces repetition of entire phrases or ideas, promoting originality in responses.';
const enabledStreamingInfoText = 'Indicates whether AI responses are sent incrementally as they are generated, reducing wait times for long outputs.';

// Splitting Settings
const splittingApiUrlInfoText = 'The endpoint that connects to the text-splitting service, dividing your document into manageable chunks for efficient processing.';
const chunkSizeInfoText = 'Determines the size of each document segment when split for indexing. Smaller chunks are easier to process but may lose some context.';
const chunkOverlapInfoText = 'Ensures continuity between chunks by overlapping segments, preserving context across boundaries.';

// Retrieval Settings
const searchThresholdInfoText = 'Sets a similarity score filter for retrieving documents. Only results meeting the specified threshold or above are returned.';
const topNResultsInfoText = 'Limits the number of most relevant documents retrieved, balancing focused retrieval with comprehensive coverage.';
