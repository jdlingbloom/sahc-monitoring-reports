import { library, dom } from '@fortawesome/fontawesome-svg-core';
import { faFile } from '@fortawesome/free-solid-svg-icons/faFile';
import { faPencilAlt } from '@fortawesome/free-solid-svg-icons/faPencilAlt';
import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
import { faSyncAlt } from '@fortawesome/free-solid-svg-icons/faSyncAlt';
import { faTimes } from '@fortawesome/free-solid-svg-icons/faTimes';

library.add(
  faFile,
  faPencilAlt,
  faPlus,
  faSyncAlt,
  faTimes,
);

dom.watch();
