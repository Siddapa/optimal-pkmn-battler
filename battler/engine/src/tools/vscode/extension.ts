import {execFile} from 'child_process';

import * as vscode from 'vscode';

type RenderedDocument = vscode.CustomDocument & {readonly preview: string};

class PkmnDebugEditorProvider implements vscode.CustomReadonlyEditorProvider {
  async openCustomDocument(
    uri: vscode.Uri,
    context: vscode.CustomDocumentOpenContext,
    token: vscode.CancellationToken
  ): Promise<RenderedDocument> {
    return {uri, preview: await preview(uri, token), dispose() {}};
  }

  resolveCustomEditor(document: RenderedDocument, webviewPanel: vscode.WebviewPanel) {
    try {
      webviewPanel.webview.options = {enableScripts: true};
      webviewPanel.webview.html = document.preview;
    } catch (error: unknown) {
      if (!(error instanceof Error)) throw error;
      vscode.window.showErrorMessage(`Error running pkmn-debug: ${error.message}`);
    }
  }
}

function preview(uri: vscode.Uri, token?: vscode.CancellationToken) {
  return new Promise<string>((resolve, reject) => {
    const child = execFile('pkmn-debug', [uri.fsPath]);
    token?.onCancellationRequested(() => {
      child.kill();
    });
    let stdout = '';
    child.stdout?.on('data', (data: Buffer) => {
      stdout += data.toString();
    });
    let stderr = '';
    child.stderr?.on('data', (data: Buffer) => {
      stderr += data.toString();
    });
    child.on('error', error => {
      reject(error);
    });
    child.on('exit', code => {
      if (code === 0) {
        resolve(stdout);
      } else {
        reject(new Error(`pkmn-debug exited with code: ${code}\n${stderr}`));
      }
    });
  });
}

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.window.registerCustomEditorProvider(
    'pkmn-debug',
    new PkmnDebugEditorProvider(),
    {webviewOptions: {
      enableFindWidget: true,
      retainContextWhenHidden: true,
    }},
  ));
}

export function deactivate() {}
