import 'package:document/document.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/ui/dialogs/embedding/embedding_dialog.form.dart';
import 'package:stacked/stacked.dart';

class EmbeddingDialogModel extends FormViewModel {
  EmbeddingDialogModel(this.tablePrefix);
  final String tablePrefix;
  final _log = getLogger('EmbeddingDialogModel');
  final _embeddingRepository = locator<EmbeddingRepository>();

  Future<void> initialise(Embedding? pEmbedding) async {
    _log.d('initialise() $pEmbedding');
    clearForm();
    Embedding? embedding;
    if (pEmbedding?.created == null) {
      embedding = await _embeddingRepository.getEmbeddingById(pEmbedding!.id!);
    } else {
      embedding = pEmbedding;
    }

    idValue = embedding?.id;
    contentValue = embedding?.content;
    embeddingValue = embedding?.embedding.join(', ');
    metadataValue = embedding?.metadata.toString();
    createdValue = embedding?.created.toString();
    updatedValue = embedding?.updated.toString();
    scoreValue = embedding?.score?.toStringAsFixed(2);
  }
}
