import 'package:flutter/material.dart';

const splitApiUrlKey = 'SPLIT_API_URL';
const chunkSizeKey = 'CHUNK_SIZE';
const chunkOverlapKey = 'CHUNK_OVERLAP';
const embeddingsModelKey = 'EMBEDDINGS_MODEL';
const embeddingsApiUrlKey = 'EMBEDDINGS_API_URL';
const embeddingsApiKey = 'EMBEDDINGS_API_KEY';
const embeddingsDimensionsKey = 'EMBEDDINGS_DIMENSIONS';
const embeddingsApiBatchSizeKey = 'EMBEDDINGS_API_BATCH_SIZE';
const embeddingsDatabaseBatchSizeKey = 'EMBEDDINGS_DB_BATCH_SIZE';
const embeddingsCompressedKey = 'EMBEDDINGS_COMPRESSED';
const searchTypeKey = 'SEARCH_TYPE';
const searchIndexKey = 'SEARCH_INDEX';
const searchThresholdKey = 'SEARCH_THRESHOLD';
const retrieveTopNResultsKey = 'RETRIEVE_TOP_N_RESULTS';
const generationModelKey = 'GENERATION_MODEL';
const generationApiUrlKey = 'GENERATION_API_URL';
const generationApiKey = 'GENERATION_API_KEY';
const systemPromptKey = 'SYSTEM_PROMPT';
const promptTemplateKey = 'PROMPT_TEMPLATE';
const temperatureKey = 'TEMPERATURE';
const topPKey = 'TOP_P';
const repetitionPenaltyKey = 'REPETITION_PENALTY';
const maxTokensKey = 'MAX_TOKENS';
const stopKey = 'STOP';
const streamKey = 'STREAM';
const userIdKey = 'USER_ID';
const promptsKey = 'PROMPTS';

const splitApiUriPath = '/split';
const embeddingsApiUriPath = '/embeddings';
const generationApiUriPath = '/chat/completions';
const contextPlaceholder = '{context}';
const instructionPlaceholder = '{instruction}';
const litellm = 'litellm';

const defaultTablePrefix = 'main';
const defaultChunkSize = '500';
const defaultChunkOverlap = '50';
const defaultEmbeddingsDimensions = '384';
const defaultEmbeddingsApiBatchSize = '50';
const defaultEmbeddingsDatabaseBatchSize = '50';
const defaultEmbeddingsCompressed = 'false';
const defaultSearchThreshold = '0.6';
const defaultRetrieveTopNResults = '3';
const defaultSystemPrompt = '''
You are a helpful assistant that will follow user instructions closely.''';
const defaultPromptTemplate = '''
Answer the question based on the following information:
{context}
If the available information is insufficient or inadequate, just tell the user you don't know the answer.

Question: {instruction}

Answer: ''';
const defaultTemperature = '0.7';
const defaultTopP = '0.95';
const defaultRepetitionPenalty = '1.1';
const defaultMaxTokens = '256';
const defaultStream = 'true';

const surrealIndxdbEndpoint = 'indxdb://surreal';
const surrealHttpEndpoint = 'http://127.0.0.1:8000/rpc';
const surrealNamespace = 'surreal';
const surrealDatabase = 'surreal';
const surrealUsername = 'root';
const surrealPassword = 'root';

const appTitle = 'RAG.WTF';
const appSubTitle = 'Your Everyday AI Buddy';
const gitHubRepoUrl = 'https://github.com/limcheekin/rag';
const appTablePrefix = '__app';
const defaultThemeMode = ThemeMode.system;
const themeModeKey = 'THEME_MODE';
const dialogMaxWidth = 840.0;
