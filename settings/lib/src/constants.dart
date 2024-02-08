import 'package:flutter/material.dart';

const splitApiUrlKey = 'SPLIT_API_URL';
const chunkSizeKey = 'CHUNK_SIZE';
const chunkOverlapKey = 'CHUNK_OVERLAP';
const embeddingsModelKey = 'EMBEDDINGS_MODEL';
const embeddingsApiUrlKey = 'EMBEDDINGS_API_URL';
const embeddingsApiKey = 'EMBEDDINGS_API_KEY';
const embeddingsDimensionsKey = 'EMBEDDINGS_DIMENSIONS';
const embeddingsApiBatchSizeKey = 'EMBEDDINGS_API_BATCH_SIZE';
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
const topKKey = 'TOP_K';
const maxTokensKey = 'MAX_TOKENS';
const stopKey = 'STOP';
const streamKey = 'STREAM';
const userIdKey = 'USER_ID';

const undefined = 'undefined';
const splitApiUriPath = '/split';
const embeddingsApiUriPath = '/embeddings';
const generationApiUriPath = '/chat/completions';
const String contextPlaceholder = '{context}';
const String instructionPlaceholder = '{instruction}';

const defaultTablePrefix = 'main';
const surrealEndpoint = 'indxdb://rag';
const surrealNamespace = 'rag';
const surrealDatabase = 'rag';

const appTitle = 'RAG.WTF';
const appTablePrefix = '__app';
const defaultThemeMode = ThemeMode.system;
const themeModeKey = 'THEME_MODE';
